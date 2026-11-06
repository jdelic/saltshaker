#
# Creates the authserver permissions for all read and write scopes of the configured WebDav folders and makes
# sure the SSO domain has a JWT key.
#

include:
    - mn.cas.sync


{% if pillar.get('apache2', {}).get('webdav', {}).get('enabled', False) %}
{% set permissions = [] %}
{% for sitedef in pillar['apache2']['webdav'].get('sites', []) %}
    {% for sitename, siteconfig in sitedef.items() %}
        {% for folderdef in siteconfig.get('folders', []) %}
            {% for foldername, folderconfig in folderdef.items() %}
                {% for perm in folderconfig.get('read-scopes', []) + folderconfig.get('write-scopes', []) %}
                    {% if perm not in permissions %}
                        {% do permissions.append(perm) %}
                    {% endif %}
                {% endfor %}
            {% endfor %}
        {% endfor %}
    {% endfor %}
{% endfor %}

{% for perm in permissions|sort %}
authserver-webdav-{{perm}}:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin permissions --settings=authserver.settings create
            --name "WebDav site access: {{perm}}" "{{perm}}"
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin permissions --settings=authserver.settings list
            --filter-permission={{perm}}
        - require:
            - cmd: authserver-sync


{% endfor %}

{% set auth_domain = pillar['authserver'].get('sso-auth-domain', pillar['authserver']['hostname']) %}
authserver-webdav-ensure-domain:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin domain --settings=authserver.settings create
            --create-key jwt
            {%- if pillar['authserver'].get('sso-allow-subdomain-signing', False) %} --jwt-allow-subdomain-signing{% endif %}
            {{auth_domain}}
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin domain --settings=authserver.settings search
            --include-parent-domain --require-subdomain-signing {{auth_domain}}
        - require:
            - cmd: authserver-sync
{% endif %}


# vim: syntax=yaml
