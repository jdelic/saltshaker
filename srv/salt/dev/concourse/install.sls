#
# Installs the Concourse CI server from a downloaded GO Binary in /usr/local/bin
# and sets up all necessary keys.
#
# This state is included from .worker and .server which then set up the systemd
# services to actually run concourse
#

concourse-user:
    group.present:
        - name: concourse
    user.present:
        - name: concourse
        - home: /srv/concourse
        - shell: /bin/false
        - createhome: True
        - require:
            - user: concourse


concourse-config-folder:
    file.directory:
        - name: /etc/concourse
        - user: concourse
        - group: concourse
        - mode: '0755'
        - makedirs: True
        - require:
            - user: concourse-user


concourse-private-config-folder:
    file.directory:
        - name: /etc/concourse/private
        - user: concourse
        - group: concourse
        - mode: '0750'
        - makedirs: True
        - require:
            - user: concourse-user
            - file: concourse-config-folder


# ssh-keygen -t rsa -f session_signing_key -N ''
{% for key in ["host_key", "worker_key" "session_signing_key"] %}
concourse-keys-{{key}}:
    cmd.run:
        - name: ssh-keygen -t rsa -f /etc/concourse/private/{{key}} -N ''
        - runas: concourse
        - unless: test -f /etc/concourse/private/{{key}}
        - require:
            - file: concourse-private-config-folder
            - user: concourse-user
    file.managed:
        - name: /etc/concourse/private/{{key}}
        - user: concourse
        - group: concourse
        - mode: '0640'
        - replace: False
        - require:
            - cmd: concourse-keys-{{key}}
{% endfor %}


require-concourse-keys:
    test.nop:
        - require:
{% for key in ["host_key", "worker_key" "session_signing_key"] %}
            - cmd: concourse-keys-{{key}}
{% endfor %}


concourse-install:
    file.managed:
        - name: /usr/local/bin/concourse_linux_amd64
        - source: {{pillar["urls"]["concourse"]}}
        - source_hash: {{pillar["hashes"]["concourse"]}}
        - mode: '0755'
        - user: concourse
        - group: concourse
        - use:
            - require-concourse-keys
        - require:
            - user: concourse-user


# vim: syntax=yaml
