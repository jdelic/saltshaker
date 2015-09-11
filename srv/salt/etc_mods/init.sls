#
# BASICS: etc_mods is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#

/etc/inputrc:
    file:
        - managed
        - source: salt://etc_mods/inputrc

