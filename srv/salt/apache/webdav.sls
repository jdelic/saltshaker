
include:
    - apache.install

{% set ip = pillar.get('apache2', {}).get('webdav', {}).get(
                'bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                    'internal-ip-index', 0
                )|int()]
            ) %}

{% set port = pillar.get('apache2', {}).get('webdav', {}).get('bind-port', 32080) %}


secure-webdav-basedir:
    file.directory:
        - name: /secure/webdav/
        - user: www-data
        - group: www-data
        - mode: '0750'
        - makedirs: True
        - require:
            - secure-mount
            - pkg: apache2


apache2-webdav-enable-dav:
    cmd.run:
        - name: /usr/sbin/a2enmod dav_fs
        - require_in:
            - service: apache2-service


apache2-webdav-config-folder:
    file.directory:
        - name: /etc/apache2/webdav-config
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True
        - require:
            - pkg: apache2


apache2-webdav-config-jwtkey:
    cmd.run:
        - name: >-
            /usr/local/bin/mn-authclient.py -m init --ca-file /etc/ssl/certs/ca-certificates.crt \
                -u https://{{pillar['authserver']['hostname']}}/getkey/ \
                --jwtkey /etc/apache2/webdav-config/jwt.public.pem
        - creates: /etc/apache2/webdav-config/jwt.public.pem


{% if pillar.get('apache2', {}).get('webdav', {}).get('enabled', False) %}
    {% for sitedef in pillar.get('apache2', {}).get('webdav', {}).get('sites', []) %}
        {% for site, config in sitedef.items() %}
            {% set sitecnt = loop.index %}
apache2-webdav-basedir-{{sitecnt}}:
    file.directory:
        - name: /secure/webdav/{{site}}/
        - user: www-data
        - group: www-data
        - mode: '0750'
        - makedirs: True
        - require:
            - pkg: apache2
            - file: secure-webdav-basedir


apache2-webdav-logdir-{{sitecnt}}:
    file.directory:
        - name: /secure/webdav/{{site}}/logs/
        - user: www-data
        - group: www-data
        - mode: '0750'
        - makedirs: True
        - require:
            - pkg: apache2
            - file: apache2-webdav-basedir-{{sitecnt}}


            {% for folderdef in config.get('folders', []) %}
                {% set fdcnt = loop.index %}
                {% for foldername, foldercfg in folderdef.items() %}
apache2-webdav-folders-{{sitecnt}}-{{foldername}}-{{fdcnt}}-{{loop.index}}:
    file.directory:
        - name: /secure/webdav/{{site}}/{{foldername}}/
        - user: www-data
        - group: www-data
        - mode: '0750'
        - makedirs: True
        - require:
            - pkg: apache2
            - file: apache2-webdav-basedir-{{sitecnt}}
                {% endfor %}
            {% endfor %}


apache2-webdav-config-{{sitecnt}}:
    file.managed:
        - name: /etc/apache2/sites-available/001-{{sitecnt}}-webdav.conf
        - source: salt://apache/sites/webdav.jinja.conf
        - template: jinja
        - context:
            ip: {{ip}}
            port: {{port}}
            site: {{site}}
            folders: {{config['folders']}}
            auth_url: {{pillar['authserver']['hostname']}}
            authrealm: {{config['authrealm']}}
            jwtkey: /etc/apache2/webdav-config/jwt.public.pem
        - require:
            - pkg: authclient
            - pkg: apache2
            - file: apache2-webdav-logdir-{{sitecnt}}


apache2-webdav-enable-site-{{sitecnt}}:
    file.symlink:
        - name: /etc/apache2/sites-enabled/001-{{sitecnt}}-webdav.conf
        - target: /etc/apache2/sites-available/001-{{sitecnt}}-webdav.conf
        - require:
            - file: apache2-webdav-config-{{sitecnt}}


apache2-webdav-servicedef-{{site}}:
    file.managed:
        - name: /etc/consul/services.d/webdav-{{sitecnt}}.json
        - source: salt://apache/consul/webdav.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            routing: external
            suffix: {{site|replace('.', '-')}}
            mode: http
            protocol: https
            hostname: {{site}}
            ip: {{ip}}
            port: {{port}}
            {% if 'ssl-combined-cert' in config and config['ssl-combined-cert'] != 'default' %}
            certificate: {{config['ssl-combined-cert']}}
            {% endif %}
        - require:
            - file: apache2-webdav-enable-site-{{sitecnt}}
            - service: apache2-service
            - file: consul-service-dir
        {% endfor %}
    {% endfor %}
{% endif %}


apache2-webdav-add-port-{{port}}:
    file.accumulated:
        - name: apache2-listen-ports
        - filename: /etc/apache2/ports.conf
        - text: {{ip}}:{{port}}
        - require_in:
            - file: apache2-ports-config


apache2-webdav-tcp-in{{port}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - destination: {{ip}}/32
        - dport: {{port}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables
