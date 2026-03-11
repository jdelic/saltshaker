radicale:
    pkg.installed:
        - name: radicale
#        - fromrepo: mn-radicale
#        - require:
#            - pkgrepo: maurusnet-radicale
    service.running:
        - name: radicale
        - sig: radicale
        - enable: True
        - watch:
            - file: radicale-config
            - file: radicale-rights
            - file: radicale-defaults
            - file: radicale-systemd-override
        - require:
            - pkg: radicale


radicale-secure-storage:
    file.directory:
        - name: {{pillar['calendar']['storagepath']}}
        - user: radicale
        - group: radicale
        - mode: '0750'
        - makedirs: True
        - require:
            - secure-mount
            - pkg: radicale


radicale-config:
    file.managed:
        - name: /etc/radicale/config
        - source: salt://radicale/config.jinja.conf
        - user: radicale
        - group: radicale
        - mode: '0640'
        - template: jinja
        - context:
            bindip: {{pillar.get('calendar', {}).get(
                'bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                    'internal-ip-index', 0
                )|int()]
            )}}
            bindport: {{pillar.get('calendar', {}).get('bind-port', 8990)}}
            storage_path: {{pillar['calendar']['storagepath']}}
            imap_host: {{pillar['imap-incoming']['hostname']}}
        - require:
            - file: radicale-secure-storage


radicale-rights:
    file.managed:
        - name: /etc/radicale/rights
        - source: salt://radicale/rights.jinja.conf
        - user: radicale
        - group: radicale
        - mode: '0640'
        - template: jinja


radicale-defaults:
    file.managed:
        - name: /etc/default/radicale
        - source: salt://radicale/default/radicale
        - user: root
        - group: root
        - mode: '0644'


radicale-systemd-override:
    file.managed:
        - name: /etc/systemd/system/radicale.service.d/override.conf
        - source: salt://radicale/systemd-override.jinja.conf
        - user: root
        - group: root
        - mode: '0644'
        - template: jinja
        - makedirs: True


radicale-servicedef-external:
    file.managed:
        - name: /etc/consul/services.d/radicale-external.json
        - source: salt://radicale/consul/radicale.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            routing: external
            protocol: https
            mode: http
            ip: {{pillar.get('calendar', {}).get(
                'bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                    'internal-ip-index', 0
                )|int()]
            )}}
            port: {{pillar.get('calendar', {}).get('bind-port', 8990)}}
            hostname: imap.service.consul
        - require:
            - service: radicale
            - file: consul-service-dir


radicale-tcp-in{{pillar.get('radicale', {}).get('bind-port', 8990)}}-recv-ipv4:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - source: '0/0'
        - destination: {{pillar.get('calendar', {}).get(
              'bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                  'internal-ip-index', 0
              )|int()]
          )}}
        - dport: {{pillar.get('calendar', {}).get('bind-port', 8990)}}
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup


{% if pillar.get('duplicity-backup', {}).get('enabled', False) %}
radicale-backup-symlink:
    file.symlink:
        - name: /etc/duplicity.d/daily/folderlinks/radicale
        - target: {{pillar['calendar']['storagepath']}}
        - require:
            - file: radicale-secure-storage
{% else %}
radicale-backup-symlink-absent:
    file.absent:
        - name: /etc/duplicity.d/daily/folderlinks/radicale
{% endif %}
