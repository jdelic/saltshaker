# Restic is an open-source, zero-knowledge encrypted, incremental backup solution supporting
# Amazon S3, SFTP, Google Storage and many other endpoints.

restic:
    file.managed:
        - name: /usr/local/bin/restic.bz2
        - source: {{pillar["urls"]["restic"]}}
        - source_hash: {{pillar["hashes"]["restic"]}}
        - unless: test -f /usr/local/bin/restic
    cmd.run:
        - name: /bin/bzip2 -d /usr/local/bin/restic.bz2
        - creates: /usr/local/bin/restic
        - onchanges:
            - file: restic


restic-permissions:
    file.managed:
        - name: /usr/local/bin/restic
        - user: root
        - group: root
        - mode: '0755'
        - require:
            - cmd: restic
