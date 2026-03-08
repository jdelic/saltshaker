include:
    - standardnotes.sync

{% set standardnotes = pillar.get('standardnotes', {}) %}
{% set ip = standardnotes.get(
        'bind-ip',
        grains['ip_interfaces'][pillar['ifassign']['internal']][
            pillar['ifassign'].get('internal-ip-index', 0)|int
        ]
    )
%}

{% set port = pillar.get('standardnotes', {}).get('bind-port', 31300) %}
{% set webapp_port = pillar.get('standardnotes', {}).get('webapp-bind-port', 31301) %}


standardnotes-docker-compose-plugin:
    pkg.installed:
        - name: docker-compose-plugin


standardnotes-config-dir:
    file.directory:
        - name: /etc/standardnotes
        - user: root
        - group: root
        - mode: '0750'
        - makedirs: True


standardnotes-base-dir:
    file.directory:
        - name: /secure/standardnotes
        - user: root
        - group: root
        - mode: '0750'
        - makedirs: True
        - require:
            - secure-mount


standardnotes-db-import-dir:
    file.directory:
        - name: /secure/standardnotes/db-import
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True
        - require:
            - file: standardnotes-base-dir


standardnotes-db-dir:
    file.directory:
        - name: /secure/standardnotes/db
        - user: root
        - group: root
        - mode: '0750'
        - makedirs: True
        - require:
            - file: standardnotes-base-dir


standardnotes-logs-dir:
    file.directory:
        - name: /secure/standardnotes/logs
        - user: root
        - group: root
        - mode: '0750'
        - makedirs: True
        - require:
            - file: standardnotes-base-dir


standardnotes-uploads-dir:
    file.directory:
        - name: /secure/standardnotes/uploads
        - user: root
        - group: root
        - mode: '0750'
        - makedirs: True
        - require:
            - file: standardnotes-base-dir


standardnotes-redis-dir:
    file.directory:
        - name: /secure/standardnotes/redis
        - user: root
        - group: root
        - mode: '0750'
        - makedirs: True
        - require:
            - file: standardnotes-base-dir


standardnotes-envfile-base:
    file.managed:
        - name: /etc/standardnotes/.env
        - user: root
        - group: root
        - mode: '0640'
        - contents: |
            # Managed by Salt
            DB_HOST=db
            DB_PORT=3306
            DB_USERNAME={{standardnotes.get('db-username', 'stdnotes')}}
            DB_PASSWORD={{pillar['dynamicsecrets']['standardnotes-db']}}
            DB_DATABASE={{standardnotes.get('db-database', 'standardnotes')}}
            DB_TYPE=mysql
            REDIS_PORT=6379
            REDIS_HOST=cache
            CACHE_TYPE=redis
            MYSQL_ROOT_PASSWORD={{pillar['dynamicsecrets']['standardnotes-db-root']}}
            AUTH_JWT_SECRET={{pillar['dynamicsecrets']['standardnotes-auth-jwt-secret']}}
            AUTH_SERVER_ENCRYPTION_SERVER_KEY={{pillar['dynamicsecrets']['standardnotes-auth-server-encryption-server-key-hex']}}
            VALET_TOKEN_SECRET={{pillar['dynamicsecrets']['standardnotes-valet-token-secret']}}
            AUTH_SERVER_DISABLE_USER_REGISTRATION=true
            DISABLE_USER_REGISTRATION=true
            COOKIE_DOMAIN={{standardnotes['cookie-domain']}}
            COOKIE_SAME_SITE={{standardnotes.get('cookie-same-site', 'None')}}
            COOKIE_SECURE={{'false' if not standardnotes.get('cookie-secure', True) else 'true'}}
            COOKIE_PARTITIONED={{'true' if standardnotes.get('cookie-partitioned', False) else 'false'}}
        - require:
            - file: standardnotes-config-dir


standardnotes-compose-file:
    file.managed:
        - name: /etc/standardnotes/docker-compose.yml
        - source: salt://standardnotes/docker-compose.jinja.yml
        - template: jinja
        - user: root
        - group: root
        - mode: '0640'
        - context:
            ip: {{ip}}
            port: {{port}}
            standardnotes: {{standardnotes}}
        - require:
            - file: standardnotes-config-dir


standardnotes-localstack-bootstrap:
    file.managed:
        - name: /etc/standardnotes/localstack_bootstrap.sh
        - source: salt://standardnotes/localstack_bootstrap.sh
        - user: root
        - group: root
        - mode: '0755'
        - require:
            - file: standardnotes-config-dir


standardnotes-webapp-default-sync-script:
    file.managed:
        - name: /etc/standardnotes/webapp_default_sync_server.sh
        - source: salt://standardnotes/webapp_default_sync_server.sh
        - user: root
        - group: root
        - mode: '0755'
        - require:
            - file: standardnotes-config-dir


standardnotes-add-user-script:
    file.managed:
        - name: /usr/local/bin/standardnotes-add-user
        - source: salt://standardnotes/standardnotes-add-user.sh
        - user: root
        - group: root
        - mode: '0750'
        - require:
            - file: standardnotes-envfile-base


standardnotes-systemd:
    systemdunit.managed:
        - name: /etc/systemd/system/standardnotes-compose.service
        - source: salt://standardnotes/standardnotes-compose.jinja.service
        - template: jinja
        - user: root
        - group: root
        - mode: '0644'
    service.running:
        - name: standardnotes-compose
        - enable: True
        - require:
            - pkg: standardnotes-docker-compose-plugin
            - file: standardnotes-base-dir
            - file: standardnotes-db-dir
            - file: standardnotes-logs-dir
            - file: standardnotes-uploads-dir
            - file: standardnotes-db-import-dir
            - file: standardnotes-redis-dir
            - file: standardnotes-envfile-base
            - file: standardnotes-compose-file
            - file: standardnotes-localstack-bootstrap
            - file: standardnotes-webapp-default-sync-script
            - file: standardnotes-add-user-script
            - cmd: standardnotes-sync
        - watch:
            - file: standardnotes-envfile-base
            - file: standardnotes-compose-file
            - file: standardnotes-localstack-bootstrap
            - file: standardnotes-webapp-default-sync-script
            - systemdunit: standardnotes-systemd


standardnotes-http-tcp-in{{port}}-ipv4:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - source: '0/0'
        - destination: {{ip}}/32
        - dport: {{port}}
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup


standardnotes-webapp-http-tcp-in{{webapp_port}}-ipv4:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - source: '0/0'
        - destination: {{ip}}/32
        - dport: {{webapp_port}}
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup


standardnotes-bridge-tcp-ipv4-accept:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - source: {{pillar['standardnotes']['bridge-cidr']}}
        - destination: {{pillar['standardnotes']['bridge-cidr']}}
        - if: standardnotes0
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - require:
            - sls: basics.nftables.setup


standardnotes-bridge-udp-ipv4-accept:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - source: {{pillar['standardnotes']['bridge-cidr']}}
        - destination: {{pillar['standardnotes']['bridge-cidr']}}
        - if: standardnotes0
        - proto: udp
        - save: True
        - require:
            - sls: basics.nftables.setup


standardnotes-bridge-ipv4-forward-accept:
    nftables.append:
        - table: filter
        - chain: forward
        - family: ip4
        - jump: accept
        - if: {{pillar['ifassign']['internal']}}
        - of: standardnotes0
        - match: state
        - connstate: new
        - save: True
        - require:
            - sls: basics.nftables.setup


standardnotes-bridge-ipv4-forward-reverse:
    nftables.append:
        - table: filter
        - chain: forward
        - family: ip4
        - jump: accept
        - if: standardnotes0
        - match: state
        - connstate: new
        - save: True
        - require:
            - sls: basics.nftables.setup


standardnotes-pdns-recursor-cidr:
    file.accumulated:
        - name: powerdns-recursor-additional-cidrs
        - filename: /etc/powerdns/recursor.d/saltshaker.yml
        - text: {{pillar['standardnotes']['bridge-cidr']}}
        - require_in:
            - file: pdns-recursor-config


standardnotes-servicedef-external:
    file.managed:
        - name: /etc/consul/services.d/standardnotes-api-external.json
        - source: salt://standardnotes/consul/standardnotes.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            service: standardnotes-api
            suffix: ext
            ip: {{ip}}
            port: {{port}}
            hostname: {{standardnotes['hostname']}}
        - require:
            - file: consul-service-dir


standardnotes-webapp-servicedef-external:
    file.managed:
        - name: /etc/consul/services.d/standardnotes-web-external.json
        - source: salt://standardnotes/consul/standardnotes.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            service: standardnotes-web
            suffix: ext
            ip: {{ip}}
            port: {{webapp_port}}
            hostname: {{standardnotes['webapp-hostname']}}
        - require:
            - file: consul-service-dir


{% if pillar.get('duplicity-backup', {}).get('enabled', False) %}
standardnotes-backup-symlink:
    file.symlink:
        - name: /etc/duplicity.d/daily/folderlinks/standardnotes
        - target: /secure/standardnotes
        - require:
            - file: standardnotes-base-dir


standardnotes-config-backup-symlink:
    file.symlink:
        - name: /etc/duplicity.d/daily/folderlinks/standardnotes-config
        - target: /etc/standardnotes
        - require:
            - file: standardnotes-config-dir
{% else %}
standardnotes-backup-symlink-absent:
    file.absent:
        - name: /etc/duplicity.d/daily/folderlinks/standardnotes


standardnotes-config-backup-symlink-absent:
    file.absent:
        - name: /etc/duplicity.d/daily/folderlinks/standardnotes-config
{% endif %}
