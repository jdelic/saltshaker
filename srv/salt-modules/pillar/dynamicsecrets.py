# -* encoding: utf-8 *-

import os
import uuid
import base64
import logging
import sqlite3

from Crypto.PublicKey import RSA  # zeromq depends on pycrypto and salt depends on 0mq, so we know pycrypto exists


_log = logging.getLogger(__name__)
_log.info("dynamic secrets module loaded")

_DEFAULT_PATH = "/etc/salt/dynamicsecrets.sqlite"


try:
    import typing
except ImportError:
    pass
else:
    if typing.TYPE_CHECKING:
        from typing import Union, Dict, List


class DynamicSecretsStore(object):
    def __init__(self, path):
        # type: (str) -> None
        self._conn = None

        if not os.path.exists(os.path.dirname(path)):
            _log.error("Path %s does not exist for file %s",
                       os.path.basename(path), path)

        dbexists = os.path.exists(path)
        self._conn = sqlite3.connect(path, isolation_level=None)

        if not dbexists:
            self._conn.execute("""
                CREATE TABLE store (
                    secretname VARCHAR(255),
                    secret TEXT,
                    host VARCHAR(255) NOT NULL DEFAULT "*"
                )"""
            )

    @staticmethod
    def _deserialize_secret(secret):
        # type: (str) -> Union[Dict[str, str], str]
        if secret.startswith("-----BEGIN RSA PRIVATE KEY"):
            key = RSA.importKey(secret)
            return {
                "key": key.exportKey("PEM"),
                "public": key.exportKey("OpenSSH"),
                "public_pem": key.publickey().exportKey("PEM"),
            }
        else:
            return secret

    def save(self, secret_name, secret, host="*"):
        # type: (str, str, str) -> None
        c = self._conn.cursor()
        try:
            c.execute("REPLACE INTO store (secretname, secret, host) VALUES (?, ?, ?)",
                      (secret_name, secret, host,))
        finally:
            c.close()

    def load(self, secret_name, host="*"):
        # type: (str, str) -> Union[Dict[str, str], str]
        c = self._conn.cursor()
        try:
            q = "SELECT secret FROM store WHERE secretname=? AND host=?"
            c.execute(q, (secret_name, host,))
            row = c.fetchone()
            if row is None:
                raise KeyError("No such key '%s' for host '%s'" % (secret_name, host,))
            return self._deserialize_secret(row[0])
        finally:
            c.close()

    def exists(self, secret_name, host="*"):
        # type: (str, str) -> bool
        c = self._conn.cursor()
        c.execute("SELECT count(*) FROM store WHERE secretname=? AND host=?", (secret_name, host,))
        return c.fetchone()[0] > 0

    def delete(self, secret_name, host="*"):
        # type: (str, str) -> None
        c = self._conn.cursor()
        try:
            c.execute("DELETE FROM store WHERE secretname=? AND host=?", (secret_name, host,))
        finally:
            c.close()


class DynamicSecretsPillar(DynamicSecretsStore):
    _PWDICT = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"

    def __init__(self, *args, **kwargs):
        super(DynamicSecretsPillar, self).__init__(*args, **kwargs)

    def _alphaencoding(self, rndstring):
        # type: (Union[str, bytes]) -> str
        pwstr = "".join([
                    str(self._PWDICT[(c & 0xf0) >> 4]) +  # c >= 64 are 2 chars
                    str(self._PWDICT[c & 0x0f])
                    if c >= 64 else self._PWDICT[c]  # c < 64 is 1 char
                    for c in [
                        ord(b) for b in rndstring
                    ]
                ])
        return pwstr

    def create(self, secret_config, secret_name, host="*"):
        # type: (Dict[str, Union[str, int, bool]], str, str) -> Union[Dict[str, str], str]
        secret_type = "password"
        encode = None
        length = 16
        if "encode" in secret_config:
            encode = secret_config["encode"]
            if encode not in ["base64", "alpha"]:
                raise ValueError("Not a valid encoding (must be 'base64' or 'alpha'): %s", encode)
        if "length" in secret_config:
            try:
                length = int(secret_config["length"])
            except ValueError:
                raise ValueError("Not a valid length specification: %s", secret_config["length"])
        if "type" in secret_config:
            if secret_config["type"] in ["password", "rsa", "uuid"]:
                secret_type = secret_config["type"]
            else:
                raise ValueError("Not a valid secret type: %s", secret_config["type"])

        if secret_type == "password":
            if encode == "base64":
                self.save(secret_name, base64.b64encode(os.urandom(length)), host)
            else:
                self.save(secret_name, self._alphaencoding(os.urandom(length)), host)
        elif secret_type == "rsa":
            if length < 2048:
                keylen = 2048
            else:
                keylen = length

            key = RSA.generate(keylen)
            # Save only the private key to the database, we calculate the public key on read
            self.save(secret_name, key.exportKey("PEM"), host)
        elif secret_type == "uuid":
            # uuid.uuid4() uses os.urandom(), so this should be reasonably unguessable
            self.save(secret_name, str(uuid.uuid4()), host)

        return self.load(secret_name, host)

    def get_or_create(self, secret_config, secret_name, host="*"):
        # type: (Dict[str, Union[str, int, bool]], str, str) -> Union[Dict[str, str], str]
        if self.exists(secret_name, host):
            return self.load(secret_name, host)
        else:
            return self.create(secret_config, secret_name, host)


def match_minion_id(minion_id, hostconfig):
    # type: (str, Dict[str, List[str]]) -> List[str]
    matching_keys = []  # type: List[str]
    for match_str in hostconfig:  # type: str
        if match_str == "*":
            matching_keys.append(match_str)
            continue

        matcher = match_str
        func = str.__eq__
        if matcher.endswith("*"):
            match = matcher[:-1]
            func = str.startswith
        if matcher.startswith("*"):
            matcher = matcher[1:]
            if func == str.startswith:
                func = str.__contains__
            else:
                func = str.endswith
        if func(minion_id, matcher):  # type: ignore
            matching_keys.append(match_str)
    return matching_keys


def ext_pillar(minion_id, pillar, **pillarconfig):
    # type: (str, str, Dict[str, Any]) -> Dict[str, Dict[str, Union[str, Dict[str, str]]]]
    db = DynamicSecretsPillar(_DEFAULT_PATH)

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

    minion_match_keys = match_minion_id(minion_id, pillarconfig["hostmapping"])
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
