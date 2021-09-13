import re
import logging
import salt.utils.files


log = logging.getLogger(__name__)


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


def managed(name, listfile_name, signing_key_url, signed_by, dearmor=True, arch=None, require=None):
    ret = {
        "name": name,
        "changes": {},
        "pchanges": {},
        "result": True,
        "comment": "aptrepo created",
    }

    unknown_qualifiers = {}

    m = re.match(r'deb \[(.*?)\] (.*)', name.strip())
    if m:
        qualifier_str = m.group(1)
        repo_params = m.group(2)
        qualifiers = qualifier_str.split(' ')
        for q in qualifiers:
            if "=" in q:
                k, v = q.split("=", 1)

                if k.lower() == "arch" and not arch:
                    arch = v
                if k.lower() == "signed-by" and not signed_by:
                    signed_by = v

                unknown_qualifiers[k] = v
    else:
        m = re.match(r'deb (.*)', name.strip())
        if m:
            repo_params = m.group(1)
        else:
            return _error(ret, "repo format appears to not match 'deb [qualifiers] <url> <component> ...'")

    if listfile_name.startswith("/"):
        listfile_fn = listfile_name
    else:
        listfile_fn = "/etc/apt/sources.list.d/%s" % listfile_name

    repo_qualifiers = ""
    for k, v in unknown_qualifiers:
        repo_qualifiers += "%s=%s " % (k, v)
    if arch:
        repo_qualifiers += "arch=%s " % arch
    if signed_by:
        repo_qualifiers += "signed-by=%s" % signed_by
    if repo_qualifiers:
        repo_qualifiers = "[" + repo_qualifiers + "] "
    repo_str = "deb " + repo_qualifiers + repo_params + "\n"

    skip_verify = True
    if signing_key_url.startswith("salt"):
        skip_verify = False

    try:
        log.debug("creating .list file %s", listfile_fn)
        listfile_ret = __states__['file.managed'](name=listfile_fn,
                                                  user="root",
                                                  group="root",
                                                  dir_mode="0755",
                                                  contents=repo_str,
                                                  makedirs=True,
                                                  require=require)
        log.debug(listfile_ret)
        _propagate_changes(ret, listfile_ret)

        if dearmor:
            if not __salt__["file.file_exists"](signed_by):
                tmp = salt.utils.files.mkstemp()
                log.debug("downloading signed-by keyfile to %s from %s", tmp, signing_key_url)
                keyfile_ret = __states__['file.managed'](name=tmp,
                                                         source=signing_key_url,
                                                         require=require,
                                                         skip_verify=skip_verify)
                log.debug(keyfile_ret)
                _propagate_changes(ret, keyfile_ret)

                log.debug("dearmoring %s to %s", tmp, signed_by)
                req_cmd = require.append({"file": tmp}) if require else [{"file": tmp}]
                dearmor_ret = __states__['cmd.run'](name="/usr/bin/gpg --dearmor -o '%s' '%s'" % (signed_by, tmp),
                                                    creates=signed_by,
                                                    require=req_cmd)
                log.debug(dearmor_ret)
                _propagate_changes(ret, dearmor_ret)
                salt.utils.files.remove(tmp)
        else:
            if not __salt__["file.file_exists"](signed_by):
                log.debug("storing dearmored key %s in %s", signing_key_url, signed_by)
                keyfile_ret = __states__['file.managed'](name=signed_by,
                                                         url=signing_key_url,
                                                         skip_verify=skip_verify)
                log.debug(keyfile_ret)
                _propagate_changes(ret, keyfile_ret)
    except ExecutionFailure:
        pass

    return ret
