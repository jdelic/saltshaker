#
# BASICS: etc_mods is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#

inputrc:
    file.managed:
        - name: /etc/inputrc
        - source: salt://etc_mods/inputrc


# this makes sense to be here because all clients connect to Vault through their local
# smartstack-internal HAProxy, but they must have a hostname for SSL to work, so this
# alias must exist in every /etc/hosts
vault-hosts-alias:
    file.append:
        - name: /etc/hosts
        - text: 127.0.0.1    {{pillar['vault']['hostname']}}


# set up vault command-line client configuration as a convenience in /etc/profile.d
vault-envvar-config:
    file.managed:
        - name: /etc/profile.d/vaultclient.sh
        - contents: |
            export VAULT_ADDR="https://{{pillar['vault']['hostname']}}:{{pillar.get('vault', {}).get('bind-port', 8200)}}/"
            export VAULT_CACERT="{{pillar['vault']['pinned-ca-cert']}}"
        - user: root
        - group: root
        - mode: '0644'
