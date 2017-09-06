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
        - unless: test -f /usr/local/bin/exxo  # workaround for https://github.com/saltstack/salt/issues/42681
        - if_missing: /usr/local/bin/exxo
        - enforce_toplevel: False
    file.managed:
        - name: /usr/local/bin/exxo
        - mode: '0755'
        - user: root
        - group: root
        - require:
            - archive: exxo
