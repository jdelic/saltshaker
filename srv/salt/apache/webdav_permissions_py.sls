#!pydsl
# vim: syntax=python

if __pillar__.get('apache2', {}).get('webdav', {}).get('enabled', False):
    permissions = set()

    for sitedef in __pillar__.get('apache2', {}).get('webdav', {}).get('sites', []):
        for sitename, siteconfig in sitedef.items():
            for folderdef in siteconfig.get('folders', []):
                for foldername, folderconfig in folderdef.items():
                    for perm in folderconfig.get('read-scopes', []):
                        permissions.add(perm)
                    for perm in folderconfig.get('write-scopes', []):
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

    auth_domain = __pillar__['authserver'].get('sso-auth-domain', __pillar__['authserver']['hostname'])
    ad_cmd = state('authserver-webdav-ensure-domain').cmd
    ad_cmd.run(
        name="/usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ "
             "/usr/local/authserver/bin/django-admin.py domain --settings=authserver.settings create "
             "--create-key jwt %s %s" %
             ("--jwt-allow-subdomain-signing" if __pillar__['authserver'].get('sso-allow-subdomain-signing', False)
              else "", auth_domain),
        unless="/usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ "
               "/usr/local/authserver/bin/django-admin.py domain --settings=authserver.settings list " \
               "--include-parent-domain %s" % auth_domain
    )
