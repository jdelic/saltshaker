import logging
import os

import salt.utils.files
import salt.utils.itertools
import salt.utils.odict
import salt.utils.path
import salt.utils.stringutils


log = logging.getLogger(__name__)
_DEFAULT_COMMAND_TIMEOUT_SECS = 0

class ExecutionFailure(Exception):
    def __init__(self, state, *args):
        self.state = state
        super().__init__(*args)


def _error(ret, err_msg):
    ret['result'] = False
    ret['comment'] = err_msg
    return ret


def _propagate_changes(myret, theirret):
    if theirret["result"] is False and myret["result"]:
        myret["result"] = False
        myret["comment"] = "Substate %s failed" % theirret["name"]

    if theirret.get("changes", {}):
        myret["changes"][theirret["name"]] = theirret["changes"]
    if theirret.get("pchanges", {}):
        myret["pchanges"][theirret["name"]] = theirret["pchanges"]


def _find_pg_binary(util):
    """
    .. versionadded:: 2016.3.2

    Helper function to locate various psql related binaries
    """
    pg_bin_dir = __salt__["config.option"]("postgres.bins_dir")
    util_bin = salt.utils.path.which(util)
    if not util_bin:
        if pg_bin_dir:
            return salt.utils.path.which(os.path.join(pg_bin_dir, util))
    else:
        return util_bin


def _connection_defaults(user=None, host=None, port=None, maintenance_db=None):
    """
    Returns a tuple of (user, host, port, db) with config, pillar, or default
    values assigned to missing values.
    """
    if not user:
        user = __salt__["config.option"]("postgres.user")
    if not host:
        host = __salt__["config.option"]("postgres.host")
    if not port:
        port = __salt__["config.option"]("postgres.port")
    if not maintenance_db:
        maintenance_db = __salt__["config.option"]("postgres.maintenance_db")

    return (user, host, port, maintenance_db)


def _run_psql(cmd, runas=None, password=None, host=None, port=None, user=None):
    """
    Helper function to call psql, because the password requirement
    makes this too much code to be repeated in each function below
    """
    kwargs = {
        "reset_system_locale": False,
        "clean_env": True,
        "timeout": __salt__["config.option"](
            "postgres.timeout", default=_DEFAULT_COMMAND_TIMEOUT_SECS
        ),
    }
    if runas is None:
        if not host:
            host = __salt__["config.option"]("postgres.host")
        if not host or host.startswith("/"):
            if "FreeBSD" in __grains__["os_family"]:
                runas = "postgres"
            elif "OpenBSD" in __grains__["os_family"]:
                runas = "_postgresql"
            else:
                runas = "postgres"

    if user is None:
        user = runas

    if runas:
        kwargs["runas"] = runas

    if password is None:
        password = __salt__["config.option"]("postgres.pass")
    if password is not None:
        pgpassfile = salt.utils.files.mkstemp(text=True)
        with salt.utils.files.fopen(pgpassfile, "w") as fp_:
            fp_.write(
                salt.utils.stringutils.to_str(
                    "{}:{}:*:{}:{}".format(
                        "localhost" if not host or host.startswith("/") else host,
                        port if port else "*",
                        user if user else "*",
                        password,
                    )
                )
            )
            __salt__["file.chown"](pgpassfile, runas, "")
            kwargs["env"] = {"PGPASSFILE": pgpassfile}

    ret = __salt__["cmd.run_all"](cmd, python_shell=False, **kwargs)

    if ret.get("retcode", 0) != 0:
        log.error("Error connecting to Postgresql server")
    if password is not None and not __salt__["file.remove"](pgpassfile):
        log.warning("Remove PGPASSFILE failed")

    return ret


def _psql_cmd(*args, **kwargs):
    """
    Return string with fully composed psql command.

    Accepts optional keyword arguments: user, host, port and maintenance_db,
    as well as any number of positional arguments to be added to the end of
    the command.
    """
    (user, host, port, maintenance_db) = _connection_defaults(
        kwargs.get("user"),
        kwargs.get("host"),
        kwargs.get("port"),
        kwargs.get("maintenance_db"),
    )
    _PSQL_BIN = _find_pg_binary("psql")
    cmd = [
        _PSQL_BIN,
        "--no-align",
        "--no-readline",
        "--no-psqlrc",
        "--no-password",
    ]  # Never prompt, handled in _run_psql.
    if user:
        cmd += ["--username", user]
    if host:
        cmd += ["--host", host]
    if port:
        cmd += ["--port", str(port)]
    if not maintenance_db:
        maintenance_db = "postgres"
    cmd.extend(["--dbname", maintenance_db])
    cmd.extend(args)
    return cmd


def _psql_prepare_and_run(
        cmd, host=None, port=None, maintenance_db=None, password=None, runas=None, user=None
):
    rcmd = _psql_cmd(
        host=host, user=user, port=port, maintenance_db=maintenance_db, *cmd
    )
    cmdret = _run_psql(
        rcmd, runas=runas, password=password, host=host, port=port, user=user
    )
    return cmdret


def present(
    name,
    createdb=None,
    createroles=None,
    encrypted=None,
    superuser=None,
    replication=None,
    inherit=None,
    login=None,
    password=None,
    default_password=None,
    refresh_password=None,
    valid_until=None,
    groups=None,
    user=None,
    maintenance_db=None,
    db_password=None,
    db_host=None,
    db_port=None,
    db_user=None,
    with_admin_option=None
):
    """
    Ensure that the named user is present with the specified privileges
    Please note that the user/group notion in postgresql is just abstract, we
    have roles, where users can be seen as roles with the LOGIN privilege
    and groups the others.

    name
        The name of the system user to manage.

    createdb
        Is the user allowed to create databases?

    createroles
        Is the user allowed to create other users?

    encrypted
        How the password should be stored.

        If encrypted is ``None``, ``True``, or ``md5``, it will use
        PostgreSQL's MD5 algorithm.

        If encrypted is ``False``, it will be stored in plaintext.

        If encrypted is ``scram-sha-256``, it will use the algorithm described
        in RFC 7677.

        .. versionchanged:: 3003

            Prior versions only supported ``True`` and ``False``

    login
        Should the group have login perm

    inherit
        Should the group inherit permissions

    superuser
        Should the new user be a "superuser"

    replication
        Should the new user be allowed to initiate streaming replication

    password
        The user's password.
        It can be either a plain string or a pre-hashed password::

            'md5{MD5OF({password}{role}}'
            'SCRAM-SHA-256${iterations}:{salt}${stored_key}:{server_key}'

        If encrypted is not ``False``, then the password will be converted
        to the appropriate format above, if not already. As a consequence,
        passwords that start with "md5" or "SCRAM-SHA-256" cannot be used.

    default_password
        The password used only when creating the user, unless password is set.

        .. versionadded:: 2016.3.0

    refresh_password
        Password refresh flag

        Boolean attribute to specify whether to password comparison check
        should be performed.

        If refresh_password is ``True``, the password will be automatically
        updated without extra password change check.

        This behaviour makes it possible to execute in environments without
        superuser access available, e.g. Amazon RDS for PostgreSQL

    valid_until
        A date and time after which the role's password is no longer valid.

    groups
        A string of comma separated groups the user should be in

    user
        System user all operations should be performed on behalf of

        .. versionadded:: 0.17.0

    db_user
        Postgres database username, if different from config or default.

    db_password
        Postgres user's password, if any password, for a specified db_user.

    db_host
        Postgres database host, if different from config or default.

    db_port
        Postgres database port, if different from config or default.

    with_admin_option
        List of Postgres users that will be given WITH ADMIN OPTION on the
        newly created role.
    """
    ret = {
        "name": name,
        "changes": {},
        "pchanges": {},
        "result": True,
        "comment": "aptrepo created",
    }

    user_ret = __states__["postgres_user.present"](
        name, createdb, createroles, encrypted, superuser, replication, inherit, login, password,
        default_password, refresh_password, valid_until, groups, user, maintenance_db, db_password,
        db_host, db_port, db_user)

    log.debug(user_ret)
    _propagate_changes(ret, user_ret)

    if with_admin_option:
        for assign_to in with_admin_option:
            grant_ret = _psql_prepare_and_run(
                ["-c", f"GRANT \"{name}\" TO \"{assign_to}\" WITH ADMIN OPTION;"],
                user=db_user, host=db_host, port=db_port, maintenance_db=maintenance_db, password=db_password,
                runas=user,
            )
            log.debug(grant_ret)
            ret["changes"][f"ADMIN OPTION FOR {assign_to}"] = name

    return ret