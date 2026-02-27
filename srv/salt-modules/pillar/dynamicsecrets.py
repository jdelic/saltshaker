# -* encoding: utf-8 *-

import logging
from typing import Union, Dict, List, Any, Optional


_log = logging.getLogger(__name__)
_log.info("dynamic secrets module loaded")

def _listdict(l: List[Union[str, Dict[str, Dict[str, Union[int, str, bool]]]]]) -> Dict[str, Dict[str, Union[int, str, bool]]]:
    result = {}
    for item in l:
        if isinstance(item, str):
            result[item] = {}
        elif isinstance(item, dict):
            result[list(item.keys())[0]] = item[list(item.keys())[0]]
    return result

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
                grainmappings = _listdict(pillarconfig["grainmapping"][grain][grainvalue])
                for secret_name in grainmappings.keys():
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

                    # only send private keys to nodes that have been explicitly configured to receive them
                    _log.debug("Grainmappings: %s", grainmappings)
                    if not grainmappings.get(secret_name, {}).get("secret-key-access", False):
                        if isinstance(this_node_secrets[secret_name], dict) and "key" in this_node_secrets[secret_name]:
                            del this_node_secrets[secret_name]["key"]

    for pillar in pillarconfig["pillarmapping"]:
        for pillarvalue in pillarconfig["pillarmapping"][pillar]:
            nodevalues = __pillars__.get(pillar, [])
            # "*" matches every grainvalue as long as there is at least one value
            if nodevalues and pillarvalue == "*" or pillarvalue in nodevalues:
                pillarmappings = _listdict(pillarconfig["pillarmapping"][pillar][pillarvalue])
                for secret_name in pillarmappings.keys():
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

                    # only send private keys to nodes that have been explicitly configured to receive them
                    if not pillarmappings.get(secret_name, {}).get("secret-key-access", False):
                        if isinstance(this_node_secrets[secret_name], dict) and "key" in this_node_secrets[secret_name]:
                            del this_node_secrets[secret_name]["key"]

    minion_match_keys = __salt__['dynamicsecrets.match_minion_id'](minion_id, pillarconfig["hostmapping"])
    for minion_match_key in minion_match_keys:
        hostmappings = _listdict(pillarconfig["hostmapping"][minion_match_key])
        for secret_name in hostmappings.keys():
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

            # only send private keys to nodes that have been explicitly configured to receive them
            if not hostmappings.get(secret_name, {}).get("secret-key-access", False):
                if isinstance(this_node_secrets[secret_name], dict) and "key" in this_node_secrets[secret_name]:
                    del this_node_secrets[secret_name]["key"]


    return {
        "dynamicsecrets": this_node_secrets
    }
