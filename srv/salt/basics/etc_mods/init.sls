#
# BASICS: etc_mods is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#

inputrc:
    file.managed:
        - name: /etc/inputrc
        - source: salt://basics/etc_mods/inputrc


# set up vault command-line client configuration as a convenience in /etc/profile.d
vault-envvar-config:
    file.managed:
        - name: /etc/profile.d/vaultclient.sh
        - contents: |
            export VAULT_ADDR="https://{{pillar['smartstack-services']['vault']['smartstack-hostname']}}:{{pillar['vault'].get('bind-port', 8200)}}/"
            export VAULT_CACERT="{{
                pillar['ssl']['service-rootca-cert'] if pillar['vault']['pinned-ca-cert'] == 'default'
                    else pillar['vault']['pinned-ca-cert']
                }}"
        - user: root
        - group: root
        - mode: '0644'


sudoers-config:
    pkg.installed:
        - name: sudo
    file.managed:
        - name: /etc/sudoers.d/salt-sudoers
        - source: salt://basics/etc_mods/salt-sudoers.jinja
        - template: jinja
        - context:
            sudoers_allow_nopasswd: {{pillar['sudoers-allow-nopasswd']}}
        - user: root
        - group: root
        - mode: '0440'
        - require:
            - pkg: sudoers-config


ensure-interfaces.d-works:
    file.append:
        - name: /etc/network/interfaces
        - text: source-directory /etc/network/interfaces.d
        - order: 2
