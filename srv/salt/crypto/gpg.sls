#
# BASICS: crypto is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#

{% set keyloc = pillar['gpg']['shared-keyring-location'] %}

gpg-access:
    group.present


gpg-shared-keyring-location:
    file.directory:
        - name: {{keyloc}}
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
        - group: root
        - mode: '0700'
        - require:
            - file: gpg-shared-keyring-location


# install all the keys which are set up in the gpg:keys:* pillars
{% for k, v in pillar.get('gpg', {}).get('keys', {}).items() %}
gpg-{{k}}:
    file.managed:
        - name: {{keyloc}}/tmp/gpg-{{k}}.asc
        - contents_pillar: gpg:keys:{{k}}
        - user: root
        - group: root
        - mode: '0400'
        - require:
            - file: gpg-shared-keyring-temp
    cmd.wait:
        - name: <
            /usr/bin/gpg
            --no-default-keyring
            --keyring {{keyloc}}/pubring.gpg
            --secret-keyring {{keyloc}}/secring.gpg
            --trustdb {{keyloc}}/trustdb.gpg
            --import {{keyloc}}/tmp/gpg-{{k}}.asc
        - watch:
            - file: gpg-{{k}}
{% endfor %}

# vim: syntax=yaml
