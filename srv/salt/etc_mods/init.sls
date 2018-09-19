#
# BASICS: etc_mods is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#

inputrc:
    file.managed:
        - name: /etc/inputrc
        - source: salt://etc_mods/inputrc


# Add hostnames for services proxied through the local smartstack-internal HAProxy.
# Some services must have a hostname for SSL to work, so these aliases can just be added
# to every /etc/hosts
{% set local_aliases = [
    pillar.get('vault', {}).get('smartstack-hostname', None),
    pillar.get('postgresql', {}).get('smartstack-hostname', None),
    pillar.get('smtp', {}).get('smartstack-hostname', None),
    pillar.get('authserver', {}).get('smartstack-hostname', None),
]%}
smartstack-hostnames:
    file.append:
        - name: /etc/hosts
        - text: 127.0.0.1    {% for alias in local_aliases %}{% if alias %}{{alias}} {% endif %}{% endfor %}
        - order: 2


# If we're in a development environment, install a list of local well-known hosts in /etc/hosts
# so we don't need a local DNS server.
{% if pillar.get('wellknown_hosts', None) %}
wellknown-etc-hosts:
    file.append:
        - name: /etc/hosts
        - text: |
            {{pillar['wellknown_hosts']|indent(12)}}
        - order: 2
{% endif %}


# set up vault command-line client configuration as a convenience in /etc/profile.d
vault-envvar-config:
    file.managed:
        - name: /etc/profile.d/vaultclient.sh
        - contents: |
            export VAULT_ADDR="https://{{pillar['vault']['smartstack-hostname']}}:{{pillar['vault'].get('bind-port', 8200)}}/"
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
        - source: salt://etc_mods/salt-sudoers.jinja
        - template: jinja
        - context:
            sudoers_allow_nopasswd: {{pillar['sudoers_allow_nopasswd']}}
        - user: root
        - group: root
        - mode: '0440'
        - require:
            - pkg: sudoers-config


ensure-interfaces.d-works:
    file.append:
        - name: /etc/network/interfaces
        - text: source /etc/network/interfaces.d/*
        - order: 2
