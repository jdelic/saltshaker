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


class DynamicSecretsStore(dict):
    def __init__(self, path):
        self._conn = None

        if not os.path.exists(os.path.dirname(path)):
            _log.error("Path %s does not exist for file %s",
                       os.path.basename(path), path)

        dbexisted = os.path.exists(path)
        self._conn = sqlite3.connect(path, isolation_level=None)

        if not dbexisted:
            self._conn.execute("""
                CREATE TABLE store (
                    secretname VARCHAR(255),
                    secret TEXT
                )"""
            )

    @staticmethod
    def _deserialize_secret(secret):
        if secret.startswith("-----BEGIN RSA PRIVATE KEY"):
            key = RSA.importKey(secret)
            return {
                "key": key.exportKey("PEM"),
                "public": key.exportKey("OpenSSH"),
                "public_pem": key.publickey().exportKey("PEM"),
            }
        else:
            return secret

    def __setitem__(self, secret_name, secret):
        c = self._conn.cursor()
        try:
            c.execute("REPLACE INTO store (secretname, secret) VALUES (?, ?)", (secret_name, secret))
        finally:
            c.close()

    def __getitem__(self, secret_name):
        c = self._conn.cursor()
        try:
            c.execute("SELECT secret FROM store WHERE secretname=?", (secret_name, ))
            row = c.fetchone()
            if row is None:
                raise KeyError(secret_name)
            return self._deserialize_secret(row[0])
        finally:
            c.close()

    def get(self, username, default=None):
        try:
            return self[username]
        except KeyError:
            return default

    def __contains__(self, secret_name):
        c = self._conn.cursor()
        c.execute("SELECT count(*) FROM store WHERE secretname=?", (secret_name,))
        return c.fetchone()[0] > 0

    def __delitem__(self, secret_name):
        c = self._conn.cursor()
        try:
            c.execute("DELETE FROM store WHERE secretname=?", (secret_name, ))
        finally:
            c.close()

    def __iter__(self):
        return (k for k, _ in self.iteritems())

    def items(self):
        return dict(self.iteritems())

    def iteritems(self):
        c = self._conn.cursor()
        try:
            c.execute("SELECT secretname, secret FROM store")
            row = c.fetchone()
            while row is not None:
                yield row[0], self._deserialize_secret(row[1])
                row = c.fetchone()
        finally:
            c.close()


class DynamicSecretsPillar(DynamicSecretsStore):
    _PWDICT = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"

    def __init__(self, *args, **kwargs):
        super(DynamicSecretsPillar, self).__init__(*args, **kwargs)

    def _alphaencoding(self, rndstring):
        pwstr = "".join([
                    str(self._PWDICT[(c & 0xf0) >> 4]) +  # c >= 64 are 2 chars
                    str(self._PWDICT[c & 0x0f])
                    if c >= 64 else self._PWDICT[c]  # c < 64 is 1 char
                    for c in [
                        ord(b) for b in rndstring
                    ]
                ])
        return pwstr

    def create(self, secret_name, encode=None, length=16, secret_type="password"):
        if secret_type == "password":
            if encode == "base64":
                self[secret_name] = base64.b64encode(os.urandom(length))
            else:
                self[secret_name] = self._alphaencoding(os.urandom(length))
        elif secret_type == "rsa":
            if length < 2048:
                keylen = 2048
            else:
                keylen = length

            key = RSA.generate(keylen)
            # Save only the private key to the database, we calculate the public key on read
            self[secret_name] = key.exportKey("PEM")
        elif secret_type == "uuid":
            # uuid.uuid4() uses os.urandom(), so this should be reasonably unguessable
            self[secret_name] = str(uuid.uuid4())


def ext_pillar(minion_id, pillar, *roledefs):
    db = DynamicSecretsPillar(_DEFAULT_PATH)

    # (
    #   {'*': [
    #       {'consul-encryptionkey':
    #           {'encode': 'base64'}
    #       }]
    #   },
    #   {'database': [
    #       'mysql-root',
    #       'debian-sys-maint'
    #   ]},
    #   ...
    # )

    # make sure all required users exist and filter the users
    # for the current minion's role
    this_node_secrets = {}
    for rd in roledefs:
        for r in rd:
            for u in rd[r]:
                secret_name = None
                secret_type = "password"
                encode = None
                length = 16
                if isinstance(u, dict):
                    secret_name = list(u.keys())[0]
                    if "encode" in u[secret_name]:
                        encode = u[secret_name]["encode"]
                    if "length" in u[secret_name]:
                        try:
                            length = int(u[secret_name]["length"])
                        except ValueError:
                            _log.error("Not a valid length specification: %s", u[secret_name]["length"])
                            continue
                    if "type" in u[secret_name]:
                        if u[secret_name]["type"] in ["password", "rsa", "uuid"]:
                            secret_type = u[secret_name]["type"]
                        else:
                            _log.error("Not a valid secret type: %s", u[secret_name]["type"])
                    else:
                        secret_type = "password"
                else:
                    secret_name = u

                if secret_name is None:
                    _log.error("dynamicsecrets created None secret_name for data %s in %s", u, r)
                    continue

                if secret_name not in db:
                    _log.debug("creating dynamic secret for %s", u)
                    db.create(secret_name, encode, length, secret_type)

                if r == "*" or r in __grains__.get("roles", []) or r == minion_id:  # "*" matches every node
                    this_node_secrets[secret_name] = db[secret_name]

    return {
        "dynamicsecrets": this_node_secrets
    }
