# -* encoding: utf-8 *-

import os
import uuid
import base64
import logging
import sqlite3
import requests

from Crypto.PublicKey import RSA  # zeromq depends on pycrypto and salt depends on 0mq, so we know pycrypto exists
from requests import RequestException
from six.moves.urllib.parse import urljoin


_log = logging.getLogger(__name__)
_log.info("dynamic secrets module loaded")

_DEFAULT_PATH = "/etc/salt/dynamicsecrets.sqlite"
_CONSUL_URL = "http://127.0.0.1:8500/"
_CONSUL_TOKEN = None
_CONSUL_TOKEN_SECRET = None


try:
    import typing
except ImportError:
    pass
else:
    if typing.TYPE_CHECKING:
        from typing import Union, Dict, List, Tuple, Any, Optional


class ConsulAclToken(dict):
    def __init__(self, accessor_id = None, secret_id = None, consul_firstrun = False, **kwargs):
        # type: (str, str, bool, Any) -> None
        super(ConsulAclToken, self).__init__(
            accessor_id=accessor_id,
            secret_id=secret_id,
            **kwargs
        )
        self['firstrun'] = consul_firstrun

    def __str__(self):
        # type: () -> str
        return self["accessor_id"]


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
                    host VARCHAR(255) NOT NULL DEFAULT "*",
                    secrettype VARCHAR(255),
                    CONSTRAINT store_pk PRIMARY KEY (secretname, host)
                )"""
                               )

    @staticmethod
    def _deserialize_secret(secret, secrettype):
        # type: (str, str) -> Union[Dict[str, str], ConsulAclToken, str]
        if secrettype == "rsa":
            key = RSA.importKey(secret)
            return {
                "key": key.exportKey("PEM"),
                "public": key.exportKey("OpenSSH"),
                "public_pem": key.publickey().exportKey("PEM"),
            }
        elif secrettype == "consul-acl-token":
            accessor_id, secret_id = secret.split(",")
            return ConsulAclToken(
                accessor_id=accessor_id,
                secret_id=secret_id
            )
        else:
            return secret

    def save(self, secret_name, secret_type, secret, host="*"):
        # type: (str, str, str, str) -> None
        c = self._conn.cursor()
        try:
            c.execute("REPLACE INTO store (secretname, secrettype, secret, host) VALUES (?, ?, ?, ?)",
                      (secret_name, secret_type, secret, host,))
        finally:
            c.close()

    def load(self, secret_name, host="*"):
        # type: (str, str) -> Union[Dict[str, str], str]
        c = self._conn.cursor()
        try:
            q = "SELECT secret, secrettype FROM store WHERE secretname=? AND host=?"
            c.execute(q, (secret_name, host,))
            row = c.fetchone()
            if row is None:
                raise KeyError("No such key '%s' for host '%s'" % (secret_name, host,))
            return self._deserialize_secret(row[0], row[1])
        finally:
            c.close()

    def loadall(self, secret_name):
        # type: (str) -> List[Tuple[Any, Any]]
        c = self._conn.cursor()
        try:
            q = "SELECT secret, secrettype, host FROM store WHERE secretname=?"
            c.execute(q, (secret_name,))
            rows = c.fetchall()
            ret = [(self._deserialize_secret(row[0], row[1]), row[2],) for row in rows]
            return ret
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

    def get_type_from_config(self, secret_config):
        # type: (Dict[str, Union[str, int, bool]]) -> str
        secret_type = "password"
        if "type" in secret_config:
            if secret_config["type"] in ["password", "rsa", "uuid", "consul-acl-token"]:
                secret_type = secret_config["type"]
            else:
                raise ValueError("Not a valid secret type: %s", secret_config["type"])
        return secret_type

    def get_consul_token(self):
        # type: () -> str
        global _CONSUL_TOKEN, _CONSUL_TOKEN_SECRET
        consul_token = None
        if _CONSUL_TOKEN:
            consul_token = _CONSUL_TOKEN
        elif _CONSUL_TOKEN_SECRET:
            consul_token = self.get_or_create({"type": "uuid"}, _CONSUL_TOKEN_SECRET)

        if not consul_token:
            raise ValueError("No ACL token for Consul in dynamicsecrets configuration")

        return consul_token

    def create(self, secret_config, secret_name, host="*"):
        # type: (Dict[str, Union[str, int, bool]], str, str) -> Union[Dict[str, str], str]
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

        secret_type = self.get_type_from_config(secret_config)
        if secret_type == "password":
            if encode == "base64":
                self.save(secret_name, secret_type, base64.b64encode(os.urandom(length)), host)
            else:
                self.save(secret_name, secret_type, self._alphaencoding(os.urandom(length)), host)
        elif secret_type == "rsa":
            if length < 2048:
                keylen = 2048
            else:
                keylen = length

            key = RSA.generate(keylen)
            # Save only the private key to the database, we calculate the public key on read
            self.save(secret_name, secret_type, key.exportKey("PEM"), host)
        elif secret_type == "uuid":
            # uuid.uuid4() uses os.urandom(), so this should be reasonably unguessable
            self.save(secret_name, secret_type, str(uuid.uuid4()), host)
        elif secret_type == "consul-acl-token":
            # creates a consul-acl-token without any policy attached to it
            try:
                resp = requests.put(
                    urljoin(_CONSUL_URL, "/v1/acl/token"),
                    headers={
                        "X-Consul-Token": self.get_consul_token(),
                    },
                    json={
                        "Description": "%s for %s" % (secret_name, host),
                        "Policies": [],
                    }
                )
            except RequestException:
                return ConsulAclToken("Unavailable", "first run", consul_firstrun=True)
            if resp.status_code == 200 and resp.headers["Content-Type"] == "application/json":
                self.save(secret_name, secret_type, "%s,%s" % (resp.json()["AccessorID"], resp.json()["SecretID"]),
                          host)
            else:
                _log.error("Invalid Consul response while creating %s (status_code=%s): %s",
                           secret_name, resp.status_code, resp.text)

        return self.load(secret_name, host)

    def check(self, secret_config, secret_name, host="*"):
        # type: (Dict[str, Union[str, int, bool]], str, str) -> bool
        exists = self.exists(secret_name, host=host)
        if exists and self.get_type_from_config(secret_config) == "consul-acl-token":
            # check if token is still valid
            resp = requests.get(
                urljoin(_CONSUL_URL, "/v1/acl/token/%s" % self.load(secret_name, host)['accessor_id']),
                headers={
                    "X-Consul-Token": self.get_consul_token()
                },
            )
            if resp.status_code == 200 and resp.headers["Content-Type"] == "application/json":
                return True
            else:
                return False
        else:
            return exists

    def get_or_create(self, secret_config, secret_name, host="*"):
        # type: (Dict[str, Union[str, int, bool]], str, str) -> Union[Dict[str, str], str]
        if self.check(secret_config, secret_name, host):
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


def __init__(opts):
    # type: (Dict[str, Any]) -> None
    global _DEFAULT_PATH, _CONSUL_URL, _CONSUL_TOKEN, _CONSUL_TOKEN_SECRET

    if "dynamicsecrets.path" in opts:
        _DEFAULT_PATH = opts["dynamicsecrets.path"]
    if "dynamicsecrets.consul_url" in opts:
        _CONSUL_URL = opts["dynamicsecrets.consul_url"]
    if "dynamicsecrets.consul_token" in opts:
        _CONSUL_TOKEN = opts["dynamicsecrets.consul_token"]
    elif "dynamicsecrets.consul_token_secret" in opts:
        _CONSUL_TOKEN_SECRET = opts["dynamicsecrets.consul_token_secret"]


store = None  # type: DynamicSecretsPillar


def get_store():
    # type: () -> DynamicSecretsPillar
    global store
    if store:
        return store
    else:
        store = DynamicSecretsPillar(_DEFAULT_PATH)
        return store


def get_or_create(secret_config, secret_name, host="*"):
    # type: (Dict[str, Union[str, int, bool]], str, str) -> Union[Dict[str, str], str]
    return get_store().get_or_create(secret_config, secret_name, host=host)


def create(secret_config, secret_name, host="*"):
    # type: (Dict[str, Union[str, int, bool]], str, str) -> Union[Dict[str, str], str]
    return get_store().create(secret_config, secret_name, host=host)


def load(secret_name, host="*"):
    # type: (str, str) -> Union[Dict[str, str], str]
    return get_store().load(secret_name, host=host)


def loadall(secret_name):
    # type: (str) -> List[Tuple[Any, Any]]
    return get_store().loadall(secret_name)


def save(secret_name, secret, host="*"):
    # type: (str, str, str) -> None
    get_store().save(secret_name, secret, host=host)
