#!pydsl
# vim: syntax=python

if __pillar__.get('apache2', {}).get('webdav', {}).get('enabled', False):
    permissions = set()

    for site in __pillar__.get('apache2', {}).get('webdav', {}).get('sites', []):
        for folder in site.get('folders', []):
            for perm in folder.get('required-scopes', []):
                permissions.add(perm)

    for perm in permissions:
        perm_cmd = state('authserver-webdav-%s' % perm).cmd
        perm_cmd.run(
            name="/usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ "
                 "/usr/local/authserver/bin/django-admin.py permissions --settings=authserver.settings create "
                 "--name \"%s\" \"%s\"" % ("WebDav site access: %s" % perm, perm),
            unless="/usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ "
                   "/usr/local/authserver/bin/django-admin.py permissions --settings=authserver.settings list | "
                   "grep \"%s\" >/dev/null" % perm,
        )
