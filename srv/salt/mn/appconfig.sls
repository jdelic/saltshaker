#
# This state is used to mark a server as supporting mn services. This
# /etc/appconfig exists, where all of the services place their config.
#
# More information can be found in ETC_APPCONFIG.md
#

appconfig:
    file.directory:
        - name: /etc/appconfig
        - mode: '0755'
        - makedirs: True
        - user: root
        - group: root


# vim: syntax=yaml

