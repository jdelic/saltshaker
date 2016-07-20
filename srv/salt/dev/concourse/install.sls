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
        - home: /etc/concourse
        - shell: /bin/false
        - createhome: False
        - require:
            - group: concourse-user


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
        - contents_pillar: ssh:concourse:public
        - user: concourse
        - group: concourse
        - mode: '0644'
        - replace: True
        - require:
            - file: concourse-config-folder


concourse-install:
    file.managed:
        - name: /usr/local/bin/concourse_linux_amd64
        - source: {{pillar["urls"]["concourse"]}}
        - source_hash: {{pillar["hashes"]["concourse"]}}
        - mode: '0755'
        - user: concourse
        - group: concourse
        - replace: False
        - require:
            - user: concourse-user
            - file: concourse-keys-host_key-public


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
