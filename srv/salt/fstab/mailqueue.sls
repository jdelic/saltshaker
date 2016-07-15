
mailqueue-mount:
    file.directory:
        - name: /mailqueue
        - makedirs: True
        - user: root
        - group: root
        - mode: '0750'
    {% if grains['envdir']['mailqueue'] is defined %}
    mount.mounted:
        - name: /mailqueue
        - device: {{grains['envdir']['mailqueue']['device']}}
        - fstype: ext4
        - opts: sync,defaults,noauto,noatime,nosuid,nodiratime,noexec
        - dump: 0
        - pass_num: 0
        - persist: True
        - require:
            - file: mailqueue-mount
    {% endif %}

# vim: syntax=yaml

