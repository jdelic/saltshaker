import functools
import os
import logging

_log = logging.getLogger(__name__)
_datapath = "/etc/salt/env.d"
_rolespath = "/etc/salt/roles.d"


# this custom grain reads /etc/salt/env.d and returns each
# file it finds as a key in a grains dictionary
def data():
    global _datapath, _log
    if not os.path.exists(_datapath):
        return {'envdir': {}}

    if _datapath.endswith(os.sep):
        _datapath = os.path.split(_datapath)[0]

    envdir = {}
    for dirpath, dirnames, filenames in os.walk(_datapath):
        for i, dirname in enumerate(dirnames):  # remove hidden folders
            if dirname.startswith('.'):
                del dirnames[i]

        if len(dirpath) > len(_datapath):
            path = dirpath[len(_datapath) + 1:].split(os.sep)  # remove leading folder and split into keys
        else:
            path = ()

        d = {}
        for dir in dirnames:
            d[dir] = {}

        for filename in filenames:
            f = open(os.path.join(dirpath, filename), "r")
            d[filename] = "".join(f.readlines()).strip()
            f.close()

        if len(path) > 0:
            parent = functools.reduce(dict.get, path[:-1], envdir)
            parent[path[-1]] = d
        else:  # this is the top-level
            envdir.update(d)

    return {'envdir': envdir}


def roles():
    global _rolespath, _log
    if not os.path.exists(_rolespath):
        return {}

    if _rolespath.endswith(os.sep):
        _rolespath = os.path.split(_rolespath)[0]

    dirpath, dirnames, filenames = next(os.walk(_rolespath))
    roles = filenames
    return {'roles': roles}

