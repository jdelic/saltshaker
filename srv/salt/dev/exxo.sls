#
# This state contains dependencies for building exxo and the included patched PyRun
#
pyrun-dependencies:
    pkg.installed:
        - pkgs:
            - libbz2-dev
            - libz-dev
            - libreadline-dev
            - libsqlite3-dev


exxo:
    archive.extracted:
        - name: /usr/local/bin
        - source: {{pillar["urls"]["exxo"]}}
        - source_hash: {{pillar["hashes"]["exxo"]}}
        - archive_format: tar
        - if_missing: /usr/local/bin/exxo
    file.managed:
        - name: /usr/local/bin/exxo
        - mode: '0755'
        - user: root
        - group: root
        - require:
            - archive: exxo
