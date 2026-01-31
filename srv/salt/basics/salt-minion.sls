#
# BASICS: salt-minion is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#


salt-minion:
    pkg.installed:
        - require:
            - pkgrepo: saltstack-repo
    service:
        - running
        - enable: True
        - require:
            - pkg: salt-minion


# vim: syntax=yaml

