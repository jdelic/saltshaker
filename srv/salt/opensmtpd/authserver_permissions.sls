#
# add the configured permission string for smtp if one is set in the pillar smtp:require-permission
#

{% if pillar.get('smtp', {}).get('require-permission', False) %}
opensmtpd-smtp-permission:
    cmd.run:
        - name: >-
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ \
                /usr/local/authserver/bin/django-admin permissions --settings=authserver.settings \
                    create --name "Send email via SMTP" "{{pillar['smtp']['require-permission']}}"
        - unless: >-
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ \
                /usr/local/authserver/bin/django-admin permissions --settings=authserver.settings \
                    list --format=json | jq -r '.[].permission_name' | grep -q "^{{pillar['smtp']['require-permission']}}$"
{% endif %}