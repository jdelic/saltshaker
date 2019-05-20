# -* encoding: utf-8 *-


class ExecutionFailure(Exception):
    def __init__(self, state, *args):
        self.state = state
        super(ExecutionFailure, self).__init__(*args)


def _propagate_changes(myret, theirret):
    if theirret["result"] is False:
        raise ExecutionFailure(theirret)

    if theirret.get("changes", {}):
        myret["changes"][theirret["name"]] = theirret["changes"]
    if theirret.get("pchanges", {}):
        myret["pchanges"][theirret["name"]] = theirret["pchanges"]


def managed(name, **kwargs):
    """
    Takes the same parameters as file.managed and works exactly the same. But after its finished, it
    will run ``systemctl --system daemon-reload``.
    :param name:
    :param kwargs:
    :return:
    """
    ret = {
        "name": name,
        "changes": {},
        "pchanges": {},
        "result": True,
        "comment": "",
    }

    require = kwargs.get("require", None)

    try:
        file_ret = __states__['file.managed'](name=name, **kwargs)
        _propagate_changes(ret, file_ret)

        if file_ret['changes']:
            cmd_ret = __states__['cmd.run'](
                name="systemctl --system daemon-reload",
                require=require
            )
            _propagate_changes(ret, cmd_ret)
    except ExecutionFailure as e:
        ret["result"] = False
        ret["comment"] = e.state["comment"] if "comment" in e.state else "Execution failure"

    return ret
