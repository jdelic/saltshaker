#
# BASICS: etc_mods is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#

inputrc:
    file.managed:
        - name: /etc/inputrc
        - source: salt://etc_mods/inputrc


vault-hosts-alias:
    file.append:
        - name: /etc/hosts
        - text: 127.0.0.1    vault.{{pillar["internal-domain"]}}
