{% if pillar.get('ci', {}).get('enabled', False) %}
include:
    - dev.concourse.sync
    - mn.cas.sync
    - vault.sync


authserver-concourse-create-permissions:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin permissions create \
                --name "CI access" ci_access
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin permissions list |
                grep "ci_access" >/dev/null 2>/dev/null
        - require:
            - cmd: authserver-sync
        - require_in:
            - cmd: concourse-sync-oauth2


authserver-concourse-create-domain:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin domain create \
                --create-key jwt \
                {{pillar['ci']['hostname']}}
        - unless: >
              /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
              /usr/local/authserver/bin/django-admin domain list |
                  grep -q "{{pillar['ci']['hostname']}}"
        - require:
            - cmd: authserver-sync
        - require_in:
              - cmd: concourse-sync-oauth2


authserver-concourse-create-client:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin oauth2 create \
                --skip-authorization \
                --redirect-uri https://{{pillar['ci']['hostname']}}/sky/issuer/callback \
                --client-type confidential \
                --grant-type authorization-code \
                --publish-to-vault secret/oauth2/concourse \
                --domain {{pillar['ci']['hostname']}} \
                concourse-ci
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin oauth2 list |
                grep "concourse-ci" >/dev/null 2>/dev/null
        - require:
            - cmd: authserver-sync
            - cmd: authserver-concourse-create-domain
        - require_in:
            - cmd: concourse-sync-oauth2


authserver-concourse-create-group:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin group create developers
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin group list | grep "developers" >/dev/null
        - require:
            - cmd: authserver-sync
        - require_in:
            - cmd: concourse-sync-oauth2


authserver-concourse-assign-group-permission:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin permissions grant group developers ci_access
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/
            /usr/local/authserver/bin/django-admin permissions show group developers | grep "ci_access" >/dev/null
        - require:
            - cmd: authserver-concourse-create-permissions
            - cmd: authserver-concourse-create-group
        - require_in:
            - cmd: concourse-sync-oauth2


authserver-concourse-require-permissions:
    cmd.run:
        - name: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env
            /usr/local/authserver/bin/django-admin permissions require concourse-ci ci_access
        - unless: >
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env
            /usr/local/authserver/bin/django-admin permissions show application concourse-ci |
                grep "ci_access" >/dev/null 2>/dev/null
        - require:
            - cmd: authserver-concourse-create-client
            - cmd: authserver-concourse-create-permissions
        - require_in:
            - cmd: concourse-sync-oauth2
{% endif %}
