
import os
import base64
import logging
import sqlite3

_log = logging.getLogger(__name__)
_log.info("dynamic password module loaded")

_DEFAULT_PATH = "/etc/salt/dynamicpasswords.sqlite"


class DynamicPasswordStore(dict):
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
                    username VARCHAR(255),
                    password VARCHAR(255)
                )"""
            )

    def __setitem__(self, username, password):
        c = self._conn.cursor()
        try:
            c.execute("REPLACE INTO store (username, password) VALUES (?, ?)", (username, password))
        finally:
            c.close()

    def __getitem__(self, username):
        c = self._conn.cursor()
        try:
            c.execute("SELECT password FROM store WHERE username=?", (username, ))
            row = c.fetchone()
            if row is None:
                raise KeyError(username)
            return row[0]
        finally:
            c.close()

    def get(self, username, default=None):
        try:
            return self[username]
        except KeyError:
            return default

    def __contains__(self, username):
        c = self._conn.cursor()
        c.execute('SELECT count(*) FROM store WHERE username=?', (username,))
        return c.fetchone()[0]>0

    def __delitem__(self, username):
        c = self._conn.cursor()
        try:
            c.execute("DELETE FROM store WHERE username=?", (username, ))
        finally:
            c.close()

    def __iter__(self):
        return (k for k, _ in self.iteritems())

    def items(self):
        return dict(self.iteritems())

    def iteritems(self):
        c = self._conn.cursor()
        try:
            c.execute("SELECT username,password FROM store")
            row = c.fetchone()
            while row is not None:
                yield row[0], row[1]
                row = c.fetchone()
        finally:
            c.close()


class DynamicPasswordPillar(DynamicPasswordStore):
    _PWDICT = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!$'

    def __init__(self, *args, **kwargs):
        super(DynamicPasswordPillar, self).__init__(*args, **kwargs)

    def _pwcreate(self):
        pwstr = ''.join([
                    str(self._PWDICT[(c & 0xf0) >> 4]) +  # c >= 64 are 2 chars
                    str(self._PWDICT[c & 0x0f])
                    if c >= 64 else self._PWDICT[c]  # c < 64 is 1 char
                    for c in [
                        ord(b) for b in os.urandom(16)
                    ]
                ])
        return pwstr

    def create(self, username):
        self[username] = self._pwcreate()


def ext_pillar(minion_id, pillar, *roledefs):
    db = DynamicPasswordPillar(_DEFAULT_PATH)

    # make sure all required users exist and filter the users
    # for the current minion's role
    serverusers = {}
    for rd in roledefs:
        for r in rd:
            for u in rd[r]:
                if u not in db:
                    _log.debug('creating dynamic password for %s', u)
                    db.create(u)
                if r in __grains__.get('roles', []):
                    serverusers[u] = db[u]

    if 'roles' not in __grains__:
        return { 'dynamicpasswords': db.items() }

    return { 'dynamicpasswords': serverusers }

