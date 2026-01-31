class ExecutionFailure(Exception):
    def __init__(self, state, *args):
        self.state = state
        super().__init__(*args)


def _error(ret, err_msg):
    ret['result'] = False
    ret['comment'] = err_msg
    return ret


def check(name: str) -> None:
    ret = {
        "name": name,
        "changes": {},
        "pchanges": {},
        "result": True,
        "comment": "",
    }

    for k,v in __grains__["ip4_interfaces"].items():
        if k == "lo":
            continue
        if len(v) == 1:
            continue
        elif len(v) > 1:
            return _error(ret, "Sanitycheck: Multiple IP addresses found for interface {}\n"
                               "{}\nYou may have networks without netfilter rules,".format(k, v))

    for k,v in __grains__["ip6_interfaces"].items():
        if k == "lo":
            continue
        if len(v) == 1:
            continue
        elif len(v) > 1:
            non_local = []
            for ip in v:
                if not ip.startswith("fe80:"):
                    non_local.append(ip)
            if len(non_local) > 1:
                return _error(ret, "Sanitycheck: Multiple IP addresses found for interface {}:\n"
                                   "{}\nYou may have networks without netfilter rules,".format(k, v))
    return ret