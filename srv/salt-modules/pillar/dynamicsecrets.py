# -* encoding: utf-8 *-

import logging


_log = logging.getLogger(__name__)
_log.info("dynamic secrets module loaded")


try:
    import typing
except ImportError:
    pass
else:
    if typing.TYPE_CHECKING:
        from typing import Union, Dict, List, Any


def ext_pillar(minion_id, pillar, **pillarconfig):
    # type: (str, str, Dict[str, Any]) -> Dict[str, Dict[str, Union[str, Dict[str, str]]]]
    db = __salt__['dynamicsecrets.get_store']()  # type: DynamicSecretsPillar

    if minion_id == __opts__['id']:
        if minion_id.endswith("_master"):
            minion_id = minion_id[0:-7]
        else:
            if 'dynamicsecrets.master_host_value' in __opts__:
                minion_id = __opts__['dynamicsecrets.master_host_value']
            else:
                from salt.exceptions import SaltConfigurationError
                raise SaltConfigurationError("If you configure your master 'id', you must set "
                                             "'dynamicsecrets.master_host_value' so dynamicsecrets can map secrets "
                                             "generated on the master to the correct minion's host name.")

    # make sure all required secrets exist and filter them
    # according to the current minion's roles or host id
    this_node_secrets = {}
    if "config" not in pillarconfig:
        pillarconfig["config"] = {}
    if "grainmapping" not in pillarconfig:
        pillarconfig["grainmapping"] = {}
    if "pillarmapping" not in pillarconfig:
        pillarconfig["pillarmapping"] = {}
    if "hostmapping" not in pillarconfig:
        pillarconfig["hostmapping"] = {}

    for grain in pillarconfig["grainmapping"]:
        for grainvalue in pillarconfig["grainmapping"][grain]:
            nodevalues = __grains__.get(grain, [])
            _log.debug("dynamicsecrets matching %s=%s in %s", grain, grainvalue, nodevalues)
            # "*" matches every grainvalue as long as there is at least one value
            if nodevalues and grainvalue == "*" or grainvalue in nodevalues:
                for secret_name in pillarconfig["grainmapping"][grain][grainvalue]:
                    _log.debug("adding secret %s to dynamicsecrets for grain match %s=%s", secret_name, grain,
                               grainvalue)

                    secret_config = pillarconfig["config"].get(secret_name, {})

                    host = "*"
                    if secret_name in pillarconfig["config"]:
                        if "unique-per-host" in pillarconfig["config"][secret_name] and \
                                pillarconfig["config"][secret_name]["unique-per-host"]:
                            host = minion_id

                    if secret_name is None:
                        _log.error("dynamicsecrets created None secret_name for data %s in %s", grain, gm)
                        continue

                    if secret_name not in this_node_secrets:
                        this_node_secrets[secret_name] = db.get_or_create(secret_config, secret_name, host)

    for pillar in pillarconfig["pillarmapping"]:
        for pillarvalue in pillarconfig["pillarmapping"][pillar]:
            nodevalues = __pillars__.get(pillar, [])
            # "*" matches every grainvalue as long as there is at least one value
            if nodevalues and pillarvalue == "*" or pillarvalue in nodevalues:
                for secret_name in pillarconfig["pillarmapping"][pillar][pillarvalue]:
                    secret_config = pillarconfig["config"].get(secret_name, {})

                    host = "*"
                    if secret_name in pillarconfig["config"]:
                        if "unique-per-host" in pillarconfig["config"][secret_name] and \
                                pillarconfig["config"][secret_name]["unique-per-host"]:
                            host = minion_id

                    if secret_name is None:
                        _log.error("dynamicsecrets created None secret_name for data %s in %s", pillar, pillarvalue)
                        continue

                    if secret_name not in this_node_secrets:
                        this_node_secrets[secret_name] = db.get_or_create(secret_config, secret_name, host)

    minion_match_keys = __salt__['dynamicsecrets.match_minion_id'](minion_id, pillarconfig["hostmapping"])
    for minion_match_key in minion_match_keys:
        for secret_name in pillarconfig["hostmapping"][minion_match_key]:
            secret_config = pillarconfig["config"].get(secret_name, {})

            host = "*"
            if secret_name in pillarconfig["config"]:
                if "unique-per-host" in pillarconfig["config"][secret_name] and \
                        pillarconfig["config"][secret_name]["unique-per-host"]:
                    host = minion_id

            if secret_name is None:
                _log.error("dynamicsecrets created None secret_name for data %s/%s in %s", minion_match_key, minion_id,
                           pillarconfig["hostmapping"][minion_match_key])
                continue

            if secret_name not in this_node_secrets:
                this_node_secrets[secret_name] = db.get_or_create(secret_config, secret_name, host)

    return {
        "dynamicsecrets": this_node_secrets
    }
