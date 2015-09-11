#
# This state is used to mark a server as supporting mn services. This
# means that daemontools is installed and /etc/mn-config exists, 
# where all of the services place their config.
#
# A server is usually being assigned this state by being assigned
# the role "servicerunner".
#

mn-config:
    file.directory:
        - name: /etc/mn-config
        - mode: '0755'
        - makedirs: True
        - user: root
        - group: root
        - require:
            - sls: djb.daemontools


# vim: syntax=yaml

