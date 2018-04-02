{% for perm in pillar.get('apache2', {}).get('webdav', {}).get('permissions', []) %}
authserver-webdav-{{perm}}:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin.py permissions --settings=authserver.settings create
                --name "WebDav site access: {{perm}}" "{{perm}}"
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin.py permissions --settings=authserver.settings list | \
            grep "{{perm}}" >/dev/null
{% endfor %}
