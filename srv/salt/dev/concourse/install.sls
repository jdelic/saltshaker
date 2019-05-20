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
        - gid: concourse
        - groups:
            - gpg-access
        - optional_groups:
            - docker
        - home: /etc/concourse
        - shell: /bin/false
        - createhome: False
        - require:
            - group: concourse-user
            - group: gpg-access


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


concourse-keys-host_key-public:
    file.managed:
        - name: /etc/concourse/host_key.pub
        - contents_pillar: dynamicsecrets:concourse-hostkey:public
        - user: concourse
        - group: concourse
        - mode: '0644'
        - replace: True
        - require:
            - file: concourse-config-folder


concourse-remove-old:
    # remove old versions of concourse
    file.absent:
        - name: /usr/local/bin/concourse_linux_amd64


concourse-install:
    archive.extracted:
        - name: /usr/local
        - source: {{pillar['urls']['concourse']}}
        - source_hash: {{pillar['hashes']['concourse']}}
        - archive_format: tar
        - if_missing: /usr/local/concourse
        - enforce_toplevel: False
    file.managed:
        - name: /usr/local/concourse/bin/concourse
        - mode: '0755'
        - user: root
        - group: root
        - require:
            - user: concourse-user
            - file: concourse-keys-host_key-public
            - archive: concourse-install


fly-install:
    archive.extracted:
        - name: /usr/local/bin
        - source: {{pillar['urls']['concourse-fly']}}
        - source_hash: {{pillar['hashes']['concourse-fly']}}
        - archive_format: tar
        - if_missing: /usr/local/bin/fly
        - enforce_toplevel: False
    file.managed:
        - name: /usr/local/bin/fly
        - mode: '0755'
        - user: root
        - group: root
        - require:
            - user: concourse-user
            - archive: fly-install


concourse-rsyslog:
    file.managed:
        - name: /etc/rsyslog.d/50-concourse.rsyslog.conf
        - source: salt://dev/concourse/50-concourse.rsyslog.conf
        - user: root
        - group: root
        - mode: '0644'


# allow workers to talk to the server on port 2222 on the internal network
concourse-tcp-out{{pillar.get('concourse-server', {}).get('tsa-port', 2222)}}-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - out-interface: {{pillar['ifassign']['internal']}}
        - dport: {{pillar.get('concourse-server', {}).get('tsa-port', 2222)}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables


# vim: syntax=yaml
