# -* encoding: utf-8 *-
import os


class ExecutionFailure(Exception):
    def __init__(self, state, *args):
        self.state = state
        super().__init__(*args)


def _error(ret, err_msg):
    ret['result'] = False
    ret['comment'] = err_msg
    return ret


def _propagate_changes(myret, theirret):
    if theirret["result"] is False:
        raise ExecutionFailure(theirret)

    if theirret.get("changes", {}):
        myret["changes"][theirret["name"]] = theirret["changes"]
    if theirret.get("pchanges", {}):
        myret["pchanges"][theirret["name"]] = theirret["pchanges"]


def present(name, user=None, group=None, dir_mode=None, require=None,
            appconfig_owner="root", appconfig_group="root",
            appconfig_path="/etc/appconfig", appconfig_mode="0755"):
    """
    A helper state to create a
    `appconfig <https://github.com/jdelic/saltshaker/blob/master/ETC_APPCONFIG.md>`_
    folder in ``/etc/appconfig/``. It will automatically create the ``env`` and
    ``files`` subfolders. All of the actual work is delegated to
    ``file.directory``.

    name
        The name of the app (``/etc/appconfig/[name]/``)

    user
        The user who owns that folder (usually/default: root)

    group
        The group who owns that folder (usually/default: root)

    dir_mode
        The permissions mode to be set on that folder (usually/default: 0755)

    appconfig_owner
        The user owning /etc/appconfig

    appconfig_group
        The group owning /etc/appconfig

    appconfig_path
        The base path of the appconfig structure. ``/etc/appconfig`` is strongly
        recommended (and the default), but on Windows this might need to change.

    appconfig_mode
        The permissions set on ``appconfig_path`` (Default: 0755)
    """
    ret = {
        "name": name,
        "changes": {},
        "pchanges": {},
        "result": True,
        "comment": "",
    }

    if "/" in name or "\\" in name:
        return _error(ret, "name (%s) can't contain '/' or '\\'" % name)

    try:
        appconfig_ret = __states__['file.directory'](name=appconfig_path,
                                                     user=appconfig_owner,
                                                     group=appconfig_group,
                                                     dir_mode=appconfig_mode,
                                                     makedirs=True)
        _propagate_changes(ret, appconfig_ret)

        app_ret = __states__['file.directory'](name=os.path.join(appconfig_path, name),
                                               user=user, group=group, dir_mode=dir_mode,
                                               require=require)
        _propagate_changes(ret, app_ret)

        files_ret = __states__['file.directory'](name=os.path.join(appconfig_path, name, "files"),
                                                 user=user, group=group, dir_mode=dir_mode,
                                                 require=require)
        _propagate_changes(ret, files_ret)

        env_ret = __states__['file.directory'](name=os.path.join(appconfig_path, name, "env"),
                                               user=user, group=group, dir_mode=dir_mode,
                                               require=require)
        _propagate_changes(ret, env_ret)
    except ExecutionFailure as e:
        ret["result"] = False
        ret["comment"] = e.state["comment"] if "comment" in e.state else "Execution failure"

    return ret
