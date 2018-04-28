
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


aptly-service:
    file.managed:
        - name: /etc/systemd/system/aptly.service
        - source: salt://dev/aptly/aptly.jinja.service
        - user: root
        - group: root
        - mode: '0644'
        - template: jinja
        - context:
            gpg_home: {{pillar['gpg']['shared-keyring-location']}}
            ip: {{ip}}
            port: {{port}}
        - require:
            - file: aptly
    service.running:
        - name: aptly
        - enable: True
        - require:
            - file: aptly-service
            - file: aptly-storage


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
