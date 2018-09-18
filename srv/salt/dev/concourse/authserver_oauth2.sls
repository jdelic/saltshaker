
include:
    - dev.concourse.sync
    - mn.cas.sync
    - vault.sync


authserver-concourse-create-permissions:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin.py permissions create \
                --name "CI access" ci_access
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin.py permissions list |
                grep "ci_access" >/dev/null 2>/dev/null
        - require:
            - cmd: authserver-sync
            - cmd: vault-sync
        - require_in:
            - cmd: concourse-sync-oauth2


authserver-concourse-create-client:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin.py oauth2 create \
                --skip-authorization \
                --redirect-uri https://{{pillar['ci']['hostname']}}/sky/issuer/callback \
                --client-type confidential \
                --grant-type authorization-code \
                --publish-to-vault secret/oauth2/concourse \
                concourse-ci
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin.py oauth2 list |
                grep "concourse-ci" >/dev/null 2>/dev/null
        - require:
            - cmd: authserver-sync
        - require_in:
            - cmd: concourse-sync-oauth2


authserver-concourse-require-permissions:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env
            /usr/local/authserver/bin/django-admin.py permissions require concourse-ci ci_access
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env
            /usr/local/authserver/bin/django-admin.py permissions show application concourse-ci |
                grep "ci_access" >/dev/null 2>/dev/null
        - require:
            - cmd: authserver-concourse-create-client
            - cmd: authserver-concourse-create-permissions
        - require_in:
            - cmd: concourse-sync-oauth2
