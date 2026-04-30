#
# add the configured permission string for imap if one is set in the pillar imap:require-permission
#

{% if pillar.get('imap', {}).get('require-permission', False) %}
dovecot-imap-permission:
    cmd.run:
        - name: >-
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ \
                /usr/local/authserver/bin/django-admin permissions --settings=authserver.settings \
                    create --name "Receive email via IMAP" "{{pillar['imap']['require-permission']}}"
        - unless: >-
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ \
                /usr/local/authserver/bin/django-admin permissions --settings=authserver.settings \
                    list --format=json | jq -r '.[].permission_name' | grep "^{{pillar['imap']['require-permission']}}$" 2>&1 >/dev/null
{% endif %}
