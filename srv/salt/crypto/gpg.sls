#
# BASICS: crypto is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#

{% set keyloc = pillar['gpg']['shared-keyring-location'] %}
{% set keylocv1 = salt['file.join'](pillar['gpg']['shared-keyring-location'], 'v1') %}


include:
    - powerdns.sync
    - vault.sync


gpg-access:
    group.present


gnupg:
    pkg.installed:
        - pkgs:
            - gnupg1
            - gnupg
            - gpgv1
            - gpgv


# this folder is needed by many commands and gpg fails in unexpected ways when it doesn't exist
gpg-root-home:
    file.directory:
        - name: /root/.gnupg
        - makedirs: True
        - user: root
        - group: root
        - mode: '0700'


gpg-shared-keyring-location:
    file.directory:
        - name: {{keyloc}}
        - makedirs: True
        - user: root
        - group: gpg-access
        - mode: '0710'
        - require:
            - group: gpg-access


# This is a temp thing, but some packages still need gnupg 1.x. Since the keyring format has
# changed for gnupg 2.1+, we keep an old version of the managed keyring in [keyloc]/v1
gpg-shared-keyring-location-v1:
    file.directory:
        - name: {{keylocv1}}
        - makedirs: True
        - user: root
        - group: gpg-access
        - mode: '0710'
        - require:
            - group: gpg-access


gpg-shared-keyring-temp:
    file.directory:
        - name: {{keyloc}}/tmp
        - makedirs: True
        - user: root
        - group: gpg-access
        - mode: '0710'
        - require:
            - file: gpg-shared-keyring-location


gpg2-batchmode-config:
    file.managed:
        - name: {{keyloc}}/gpg.conf
        - contents: |
            pinentry-mode loopback
        - user: root
        - group: gpg-access
        - mode: '0640'
        - require:
            - file: gpg-shared-keyring-location


gpg2-agent-batchmode-config:
    file.managed:
        - name: {{keyloc}}/gpg-agent.conf
        - contents: |
            allow-loopback-pinentry
        - user: root
        - group: gpg-access
        - mode: '0640'
        - require:
            - file: gpg-shared-keyring-location


# install all the keys which are set up in the gpg:keys:* pillars
{% for k, v in pillar.get('gpg', {}).get('keys', {}).items() %}
gpg-{{k}}:
    file.managed:
        - name: {{keyloc}}/tmp/gpg-{{k}}.asc
        - contents_pillar: gpg:keys:{{k}}
        - user: root
        - group: gpg-access
        - mode: '0640'
        - require:
            - file: gpg-shared-keyring-temp
            - file: gpg2-batchmode-config
            - file: gpg2-agent-batchmode-config
            - pkg: gnupg
    cmd.run:
        - unless: >
            /usr/bin/gpg \
                --batch \
                --homedir {{keyloc}} \
                --no-default-keyring \
                --list-keys "$(/usr/bin/gpg --batch --no-tty --no-default-keyring --homedir {{keyloc}} \
                    --import-options import-show --dry-run --with-colons --import \
                    {{keyloc}}/tmp/gpg-{{k}}.asc 2>/dev/null | head -1 | cut -d':' -f5)" 2>/dev/null
        # more info here
        # https://stackoverflow.com/questions/22136029/how-to-display-gpg-key-details-without-importing-it
        - name: >
            /usr/bin/gpg \
                --verbose \
                --homedir {{keyloc}} \
                --no-default-keyring \
                --batch \
                --import {{keyloc}}/tmp/gpg-{{k}}.asc
        - require:
            - file: gpg-{{k}}


gpg-{{k}}-v1:
    cmd.run:
        - unless: >
            /usr/bin/gpg1 \
                --batch \
                --homedir {{keylocv1}} \
                --no-default-keyring \
                --list-keys "$(/usr/bin/gpg --no-default-keyring --homedir {{keyloc}} \
                    --import-options import-show --dry-run --with-colons --import \
                    {{keyloc}}/tmp/gpg-{{k}}.asc | head -1 | cut -d':' -f5 2>/dev/null)" 2>/dev/null
        # more info here
        # https://stackoverflow.com/questions/22136029/how-to-display-gpg-key-details-without-importing-it
        - name: >
            /usr/bin/gpg1 \
                --verbose \
                --homedir {{keylocv1}} \
                --no-default-keyring \
                --keyring {{salt['file.join'](keylocv1, "pubring.gpg")}} \
                --secret-keyring {{salt['file.join'](keylocv1, "secring.gpg")}} \
                --trustdb {{salt['file.join'](keylocv1, "trustdb.gpg")}} \
                --batch \
                --import {{keyloc}}/tmp/gpg-{{k}}.asc
        - require:
            - file: gpg-{{k}}


gpg-establish-trust-{{k}}:
    cmd.run:
        - onlyif: >
            /usr/bin/gpg \
                --homedir {{keyloc}} \
                --no-default-keyring \
                --with-colons \
                --list-keys "$(/usr/bin/gpg --batch --no-default-keyring --homedir {{keyloc}} \
                    --import-options import-show --dry-run --with-colons --import \
                    {{keyloc}}/tmp/gpg-{{k}}.asc 2>/dev/null | head -1 | cut -d':' -f5)" 2>/dev/null | \
                grep "pub:" | cut -d':' -f2 | grep "-" >/dev/null
        - name: >
            echo "$(/usr/bin/gpg --batch --no-default-keyring --homedir {{keyloc}} \
                --import-options import-show --dry-run --with-colons \
                --import {{keyloc}}/tmp/gpg-{{k}}.asc |
                grep "fpr:" | head -1 | cut -d':' -f10 2>/dev/null):6:" |
            /usr/bin/gpg \
                --homedir={{keyloc}} \
                --batch \
                --import-ownertrust
        - require:
            - cmd: gpg-{{k}}


gpg-establish-trust-{{k}}-v1:
    cmd.run:
        - onlyif: >
            /usr/bin/gpg1 \
                --homedir {{keylocv1}} \
                --no-default-keyring \
                --with-colons \
                --list-keys "$(/usr/bin/gpg --batch --no-default-keyring --homedir {{keyloc}} \
                    --import-options import-show --dry-run --with-colons --import \
                    {{keyloc}}/tmp/gpg-{{k}}.asc | head -1 | cut -d':' -f5 2>/dev/null)" 2>/dev/null | \
                grep "pub:" | cut -d':' -f2 | grep "-" >/dev/null
        - name: >
            echo "$(/usr/bin/gpg --batch --no-default-keyring --homedir {{keyloc}} \
                --import-options import-show --dry-run --with-colons --import {{keyloc}}/tmp/gpg-{{k}}.asc |
                grep "fpr:" | head -1 | cut -d':' -f10 2>/dev/null):6:" |
            /usr/bin/gpg1 \
                --homedir={{keylocv1}} \
                --batch \
                --import-ownertrust
        - require:
            - cmd: gpg-{{k}}-v1
{% endfor %}


{% if pillar.get('gpg', {}).get('vault-create-perhost-key', False) %}
# for some reason the key sometimes gets created 1 or 2 seconds in the future, so we sleep 2 as a work-around
gpg-create-host-key:
    cmd.run:
        - name: >
            /usr/local/bin/vault write \
                "gpg/keys/{{grains['id']}}" \
                name="{{grains['id']}}" \
                generate=true \
                real_name="{{grains['id']}}" \
                key_bits=2048 \
                exportable=true; sleep 2
        - unless: >
            /usr/local/bin/vault list gpg/keys | grep "{{grains['id']}}" >/dev/null
        - env:
            - VAULT_TOKEN: "{{pillar['dynamicsecrets']['gpg-auth-token']}}"
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - require:
            - file: vault
            - cmd: powerdns-sync
            - cmd: vault-sync


gpg-import-host-key:
    cmd.run:
        - unless: >
            /usr/bin/gpg
            --batch
            --homedir {{keyloc}}
            --no-default-keyring
            --with-colons
            --list-keys "$(VAULT_TOKEN="$VAULT_READ_TOKEN" \
                          /usr/local/bin/vault read \
                              -field=fingerprint \
                              "gpg/keys/{{grains['id']}}" 2>/dev/null)" 2>/dev/null
        - name: >
            /usr/local/bin/vault read
            -field=key
            "gpg/export/{{grains['id']}}" |
            gpg --homedir {{keyloc}} --no-default-keyring --import
        - env:
            - VAULT_READ_TOKEN: "{{pillar['dynamicsecrets']['gpg-read-token']}}"
            - VAULT_TOKEN: "{{pillar['dynamicsecrets']['gpg-auth-token']}}"
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - require:
            - file: gpg-shared-keyring-location
            - cmd: gpg-create-host-key


gpg-establish-host-key-trust:
    cmd.run:
        - onlyif: >
            /usr/bin/gpg
            --batch
            --homedir {{keyloc}}
            --no-default-keyring
            --with-colons
            --list-keys "$(VAULT_TOKEN="$VAULT_READ_TOKEN" \
                          /usr/local/bin/vault read \
                              -field=fingerprint \
                              "gpg/keys/{{grains['id']}}" 2>/dev/null)" 2>/dev/null |
            grep "pub:" | cut -d':' -f2 | grep "-" >/dev/null
        - name: >
            echo "$(/usr/local/bin/vault read \
                -field=fingerprint \
                "gpg/keys/{{grains['id']}}" 2>/dev/null):6:" |
            /usr/bin/gpg
            --homedir=/etc/gpg-managed-keyring/
            --batch
            --import-ownertrust
        - env:
            - VAULT_READ_TOKEN: "{{pillar['dynamicsecrets']['gpg-read-token']}}"
            - VAULT_TOKEN: "{{pillar['dynamicsecrets']['gpg-auth-token']}}"
            - VAULT_ADDR: "https://vault.service.consul:8200/"
        - require:
            - cmd: gpg-import-host-key
{% endif %}


# require this state to make sure the GPG keyring is fully configured
managed-keyring:
    file.directory:
        - name: {{keyloc}}
        - file_mode: '0640'
        - dir_mode: '0710'
        - user: root
        - group: gpg-access
        - recurse:
            - user
            - group
            - mode
        - require:
            - group: gpg-access
            - file: gpg-shared-keyring-location
            {% for k, v in pillar.get('gpg', {}).get('keys', {}).items() %}
            - cmd: gpg-{{k}}
            {% endfor %}

# vim: syntax=yaml
