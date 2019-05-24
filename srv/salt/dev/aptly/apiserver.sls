
include:
    - dev.aptly.install


{% set port = 8100 %}
{% set ip = pillar.get('aptly', {}).get('bind-ip',
                grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                    'internal-ip-index', 0)|int()]) %}


aptly-user:
    group.present:
        - name: aptly
    user.present:
        - name: aptly
        - gid: aptly
        - groups:
            - gpg-access
        - home: /srv/aptly-api
        - shell: /bin/false
        - createhome: False
        - require:
            - group: aptly-user
            - group: gpg-access


aptly-storage:
    file.directory:
        - name: /srv/aptly-api
        - user: aptly
        - group: aptly
        - mode: '0750'
        - require:
            - user: aptly-user


aptly-service-config:
    file.managed:
        - name: /etc/aptly/aptly_api.conf
        - source: salt://dev/aptly/aptly.example.jinja.conf
        - template: jinja
        - context:
            example: False
            rootdir: /srv/aptly-api/
        - replace: False  # once modified by the user don't overwrite
        - makedirs: True
        - mode: '0644'


aptly-service:
    systemdunit.managed:
        - name: /etc/systemd/system/aptly.service
        - source: salt://dev/aptly/aptly.jinja.service
        - user: root
        - group: root
        - mode: '0644'
        - template: jinja
        - context:
            # Temporarily use gnupg v1 until aptly supports v2
            # https://github.com/aptly-dev/aptly/issues/657
            # https://github.com/aptly-dev/aptly/pull/743
            gpg_home: {{salt['file.join'](pillar['gpg']['shared-keyring-location'], 'v1')}}
            ip: {{ip}}
            port: {{port}}
        - require:
            - file: aptly
            - pkg: aptly
    service.running:
        - name: aptly
        - enable: True
        - require:
            - systemdunit: aptly-service
            - file: aptly-storage
            - file: aptly-service-config


aptly-servicedef:
    file.managed:
        - name: /etc/consul/services.d/aptly.json
        - source: salt://dev/aptly/consul/aptly.jinja.json
        - user: root
        - group: root
        - mode: '0644'
        - template: jinja
        - context:
            ip: {{ip}}
            port: {{port}}
        # no "require" for aptly-service because that would block consul from starting if
        # the aptly api server has no config file (which must be added manually) and therefor
        # doesn't start. As the consul service watches 'services.d*' it would be blocked.


aptly-tcp-in{{port}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{ip}}
        - dport: {{port}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables
