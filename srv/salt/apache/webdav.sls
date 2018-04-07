
include:
    - apache.install


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

{% set ip = pillar.get('apache2', {}).get('webdav', {}).get(
                'bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                    'internal-ip-index', 0
                )|int()]
            ) %}

{% set port = pillar.get('apache2', {}).get('webdav', {}).get('bind-port', 32080) %}


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


apache2-webdav-logdir-{{sitecnt}}:
    file.directory:
        - name: /secure/webdav/{{site}}/logs/
        - user: www-data
        - group: www-data
        - mode: '0750'
        - makedirs: True
        - require:
            - pkg: apache2


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
                {% endfor %}
            {% endfor %}

apache2-webdav-config-{{sitecnt}}:
    file.managed:
        - name: /etc/apache2/sites-available/001-{{loop.index}}-webdav.conf
        - source: salt://apache/sites/webdav.jinja.conf
        - template: jinja
        - context:
            ip: {{ip}}
            port: {{port}}
            site: {{site}}
            folders: {{config['folders']}}
            auth_url: {{pillar['authserver']['hostname']}}
            authrealm: {{config['authrealm']}}
        - require:
            - pkg: authclient
            - pkg: apache2


apache2-webdav-servicedef-{{site}}:
    file.managed:
        - name: /etc/consul/services.d/webdav-{{loop.index}}.json
        - source: salt://apache/consul/webdav.jinja.json
        - mode: '0644'
        - template: jinja
        - context:
            routing: external
            suffix: {{site|replace('.', '-')}}
            mode: http
            protocol: https
            hostname: {{site}}
            ip: {{config.get(
                    'bind-ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get(
                        'internal-ip-index', 0
                    )|int()]
                )}}
            port: {{config.get('bind-port', 32080)}}
        - require:
            - file: apache2-webdav-config-{{loop.index}}
            - service: apache2-service
            - file: consul-service-dir

        {% endfor %}
    {% endfor %}
{% endif %}
