
gemdeps:
    pkg.installed:
        - pkgs:
            - ruby
            - ruby-dev

{% if pillar["urls"].get("fpmdeps", None) %}
fpm-download-dir:
    file.directory:
        - name: /usr/local/src/fpm
        - user: root
        - group: root
        - dir_mode: 0755
        - makedirs: True
{% endif %}


fpm:
    {% if pillar["urls"].get("fpmdeps", None) %}
    archive.extracted:
        - name: /usr/local/src/fpm
        - source: {{pillar["urls"]["fpmdeps"]}}
        - source_hash: {{pillar["hashes"]["fpmdeps"]}}
        - archive_format: zip
        - if_missing: /usr/local/src/fpm/fpm-1.8.1.gem
        - enforce_toplevel: False
        - require:
            - file: fpm-download-dir
    {% endif %}
    cmd.run:
        {% if pillar["urls"].get("fpmdeps", None) %}
        - name: gem install --local fpm-1.8.1.gem
        - cwd: /usr/local/src/fpm
        - require:
            - archive: fpm
        {% else %}
        - name: gem install fpm
        {% endif %}
        - runas: root
        - unless: test -e /usr/local/bin/fpm
        - require:
            - pkg: gemdeps
