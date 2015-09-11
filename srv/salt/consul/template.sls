
consul-template:
    archive.extracted:
        - name: /usr/local/bin
        - source: https://github.com/hashicorp/consul-template/releases/download/v0.10.0/consul-template_0.10.0_linux_amd64.tar.gz
        - source_hash: md5=c09d9e77ff079e17b7097af882eab5d6
        - archive_format: tar
        - tar_options: z
        - if_missing: /usr/local/bin/consul-template
    file.copy:
        - name: /usr/local/bin/consul-template
        - source: /usr/local/bin/consul-template_0.10.0_linux_amd64/consul-template
        - force: True
        - mode: '0750'
        - user: root
        - group: root
        - onlyif: test -e /usr/local/bin/consul-template_0.10.0_linux_amd64/consul-template
        - require:
            - archive: consul-template


consul-template-cleanup:
    file.absent:
        - name: /usr/local/bin/consul-template_0.10.0_linux_amd64
        - require:
            - file: consul-template

# vim: syntax=yaml
