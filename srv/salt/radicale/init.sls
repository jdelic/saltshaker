
maurusnet-radicale:
    pkgrepo.managed:
        - humanname: repo.maurus.net-radicale
        - name: {{pillar['repos']['maurusnet-radicale']}}
        - file: /etc/apt/sources.list.d/mn-radicale.list
        - key_url: salt://mn/packaging_authority_A78049AF.pgp.key


radicale:
    pkg.installed:
        - name: radicale
        - fromrepo: mn-radicale
        - require:
            - pkgrepo: maurusnet-radicale
    service.running:
        - name: radicale
        - sig: radicale
        - enable: True
        - watch:
            - file: radicale-config
            - file: radicale-rights
        - require:
            - pkg: radicale


radicale-secure-storage:
    file.directory:
        - name: /secure/radicale
        - user: radicale
        - group: radicale
        - mode: '0750'
        - makedirs: True
        - require:
            - secure-mount


radicale-config:
    file.managed:
        - name: /etc/radicale/config
        - source: salt://radicale/config.jinja.conf
        - user: radicale
        - group: radicale
        - mode: '0640'
        - template: jinja
        - context:
            bindip:
            bindport:
            storage_path: /secure/radicale/
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
