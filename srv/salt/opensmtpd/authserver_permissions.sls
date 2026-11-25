include:
    - mn.cas.sync
    - opensmtpd.sync


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


{% set greylistd_frontend = pillar['greylistd-frontend'] %}

authserver-greylistd-frontend-create-permissions:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin permissions create \
                --name "Greylist administration" {{greylistd_frontend['require-permission']}}
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin permissions list |
                grep "{{greylistd_frontend['require-permission']}}" >/dev/null 2>/dev/null
        - require:
            - cmd: authserver-sync


authserver-greylistd-frontend-create-domain:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin domain create \
                --create-key jwt \
                {{greylistd_frontend['hostname']}}
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin domain search \
                --include-parent-domain --require-subdomain-signing "{{greylistd_frontend['hostname']}}"
        - require:
            - cmd: authserver-sync


authserver-greylistd-frontend-create-client:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin oauth2 create \
                --skip-authorization \
                --redirect-uri https://{{greylistd_frontend['hostname']}}/auth/oidc/callback \
                --client-type confidential \
                --grant-type authorization-code \
                --publish-to-vault secret/oauth2/greylistd-frontend \
                --domain {{greylistd_frontend['hostname']}} \
                greylistd-frontend
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin oauth2 list |
                grep "greylistd-frontend" >/dev/null 2>/dev/null
        - require:
            - cmd: authserver-greylistd-frontend-create-domain
            - cmd: authserver-sync


authserver-greylistd-frontend-require-permissions:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env
            /usr/local/authserver/bin/django-admin permissions require greylistd-frontend
            {{greylistd_frontend['require-permission']}}
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env
            /usr/local/authserver/bin/django-admin permissions show application greylistd-frontend |
                grep "{{greylistd_frontend['require-permission']}}" >/dev/null 2>/dev/null
        - require:
            - cmd: authserver-greylistd-frontend-create-client
            - cmd: authserver-greylistd-frontend-create-permissions
        - require_in:
            - cmd: greylistd-frontend-sync-oidc
