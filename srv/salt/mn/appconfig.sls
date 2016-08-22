#
# This state is used to mark a server as supporting mn services. This
# /etc/appconfig exists, where all of the services place their config.
# The environment variables defined in /etc/appconfig are then loaded
# using systemd's EnvironmentFile option. The systemd service definitions
# are installed by the applications themselves via DPKG.
#
# Alternatively the config options can be loaded by nomad.
#
# A server is usually being assigned this state by being assigned
# the role "servicerunner".
#

appconfig:
    file.directory:
        - name: /etc/appconfig
        - mode: '0755'
        - makedirs: True
        - user: root
        - group: root


# vim: syntax=yaml

