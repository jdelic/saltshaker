
{% set ip = pillar.get('anytype', {}).get(
        'bind-ip',
        grains['ip_interfaces'][pillar['ifassign']['internal']][
            pillar['ifassign'].get('internal-ip-index', 0)|int
        ]
    )
%}

{% set hostname = pillar['anytype']['hostname'] %}
{% bridge_cidr = pillar.get('anytype', {}).get('bridge-cidr', '192.168.57.0/24') %}
{% container_cidr = pillar.get('anytype', {}).get('container-cidr', '192.168.57.0/25') %}

anytype-base-dir:
    file.directory:
        - name: /secure/anytype
        - makedirs: True
        - user: root
        - group: root
        - mode: '0700'
        - require:
            - secure-mount


anytype-config-dir:
    file.directory:
        - name: /etc/anytype
        - makedirs: True
        - user: root
        - group: root
        - mode: '0755'


anytype-dockercompose-repo:
    git.cloned:
        - name: https://github.com/anyproto/any-sync-dockercompose
        - target: /etc/anytype/any-sync-dockercompose
        - require:
            - file: anytype-config-dir


anytype-dockercompose-override:
    file.managed:
        - name: /etc/anytype/any-sync-dockercompose/saltshaker-anytype-compose.yml
        - source: salt://anytype/saltshaker-anytype-compose.jinja.yml
        - user: root
        - group: root
        - mode: '0644'
        - template: jinja
        - context:
            bridge_cidr: {{bridge_cidr}}
            container_cidr: {{container_cidr}}
        - require:
            - git: anytype-dockercompose-repo


anytype-env-file:
    file.managed:
        - name: /etc/anytype/any-sync-dockercompose/.env.override
        - user: root
        - group: root
        - mode: '0644'
        - content: |
              EXTERNAL_LISTEN_HOSTS="{{hostname}} {{internal_ip}}"
              REDIS_PORT=6380
              ANY_SYNC_NODE_1_PORT=10001
              ANY_SYNC_NODE_1_QUIC_PORT=10011
              ANY_SYNC_NODE_2_PORT=10002
              ANY_SYNC_NODE_2_QUIC_PORT=10012
              ANY_SYNC_NODE_3_PORT=10003
              ANY_SYNC_NODE_3_QUIC_PORT=10013
              ANY_SYNC_COORDINATOR_PORT=10004
              ANY_SYNC_COORDINATOR_QUIC_PORT=10014
              ANY_SYNC_FILENODE_PORT=10005
              ANY_SYNC_FILENODE_QUIC_PORT=10015
              ANY_SYNC_CONSENSUSNODE_PORT=10006
              ANY_SYNC_CONSENSUSNODE_QUIC_PORT=10016
              STORAGE_DIR=/secure/anytype/data
        - require:
            - git: anytype-dockercompose-repo


anytype-systemdunit:
    systemdunit.managed:
        - name: /etc/systemd/system/anytype-compose.service
        - source: salt://anytype/anytype-compose.jinja.service
        - user: root
        - group: root
        - mode: '0644'
        - template: jinja
        - require:
            - file: anytype-dockercompose-override
            - file: anytype-base-dir
    service.running:
        - name: anytype-compose
        - enable: True
        - require:
            - systemdunit: anytype-systemdunit
            - file: anytype-env-file


anytype-tcp-in10001-10006-ipv4:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - source: '0/0'
        - destination: {{ip}}/32
        - dport: 10001-10006
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup


anytype-udp-in1011-1016-ipv4:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - source: '0/0'
        - destination: {{ip}}/32
        - dport: 10011-10016
        - match: state
        - connstate: new
        - proto: udp
        - save: True
        - require:
            - sls: basics.nftables.setup


anytype-bridge-forward-ipv4:
    nftables.append:
        - table: filter
        - chain: forward
        - family: ip4
        - jump: accept
        - if: {{pillar['ifassign']['internal']}}
        - of: anytype0
        - save: True
        - require:
            - sls: basics.nftables.setup


anytype-bridge-forward-ipv4-reverse:
    nftables.append:
        - table: filter
        - chain: forward
        - family: ip4
        - jump: accept
        - if: anytype0
        - of: {{pillar['ifassign']['internal']}}
        - save: True
        - require:
            - sls: basics.nftables.setup


anytype-pdns-recursor-cidr:
    file.accumulated:
        - name: powerdns-recursor-additional-cidrs
        - filename: /etc/powerdns/recursor.d/saltshaker.yml
        - text: {{bridge_cidr}}
        - require_in:
              - file: pdns-recursor-config


anytype-servicedef-tcp-external:
    file.managed:
        - name: /etc/consul/services.d/anytype-tcp.json
        - source: salt://anytype/anytype-tcp.jinja.json
        - mode: '0644'
        - user: root
        - group: root
        - template: jinja
        - context:
            hostname: {{hostname}}
            ip: {{ip}}
        - require:
            - file: consul-service-dir


anytype-servicedef-udp-external:
    file.managed:
        - name: /etc/consul/services.d/anytype-udp.json
        - source: salt://anytype/anytype-udp.jinja.json
        - mode: '0644'
        - user: root
        - group: root
        - template: jinja
        - context:
            ip: {{ip}}
        - require:
            - file: consul-service-dir


{% if pillar.get('duplicity-backup', {}).get('enabled', False) %}
anytype-backup-symlink:
    file.symlink:
        - name: /etc/duplicity.d/daily/folderlinks/anytype-secure
        - target: /secure/anytype
        - require:
            - file: anytype-base-dir


anytype-config-backup-symlink:
    file.symlink:
        - name: /etc/duplicity.d/daily/folderlinks/anytype-config
        - target: /etc/anytype
        - require:
            - file: anytype-config-dir
{% else %}
anytype-backup-symlink-absent:
    file.absent:
        - name: /etc/duplicity.d/daily/folderlinks/anytype-secure


anytype-config-backup-symlink-absent:
    file.absent:
        - name: /etc/duplicity.d/daily/folderlinks/anytype-config
{% endif %}
