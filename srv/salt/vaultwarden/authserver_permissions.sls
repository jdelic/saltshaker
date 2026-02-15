include:
    - mn.cas.sync
    - vaultwarden.sync


{% if pillar['vaultwarden'].get('enabled', False) %}

authserver-vaultwarden-create-permissions:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin permissions create \
                --name "Password Manager" password_manager_access
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin permissions list |
                grep "password_manager_access" >/dev/null 2>/dev/null
        - require:
            - cmd: authserver-sync


authserver-vaultwarden-create-domain:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin domain create \
                --create-key jwt \
                {{pillar['vaultwarden']['hostname']}}
        - unless: >
              /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
              /usr/local/authserver/bin/django-admin domain list |
                  grep -q "{{pillar['vaultwarden']['hostname']}}"
        - require:
            - cmd: authserver-sync
        - require_in:
              - cmd: vaultwarden-sync-oidc


authserver-vaultwarden-create-client:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin oauth2 create \
                --skip-authorization \
                --redirect-uri https://{{pillar['vaultwarden']['hostname']}}/identity/connect/oidc-signin \
                --client-type confidential \
                --grant-type authorization-code \
                --publish-to-vault secret/oauth2/vaultwarden \
                --domain {{pillar['vaultwarden']['hostname']}} \
                vaultwarden
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin oauth2 list |
                grep "vaultwarden" >/dev/null 2>/dev/null
        - require:
            - cmd: authserver-vaultwarden-create-domain
            - cmd: authserver-sync


authserver-vaultwarden-require-permissions:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env
            /usr/local/authserver/bin/django-admin permissions require vaultwarden password_manager_access
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env
            /usr/local/authserver/bin/django-admin permissions show application vaultwarden |
                grep "password_manager_access" >/dev/null 2>/dev/null
        - require:
            - cmd: authserver-vaultwarden-create-client
            - cmd: authserver-vaultwarden-create-permissions
        - require_in:
            - cmd: vaultwarden-sync-oidc

{% endif %}