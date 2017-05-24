
data-mount:
    file.directory:
        - name: /data
        - user: root
        - group: root
        - mode: '0755'
    {% if grains['envdir']['data'] is defined %}
    mount.mounted:
        - name: /data
        - device: {{grains['envdir']['data']['device']}}
        - fstype: ext4
        - opts: data=journal,defaults,noatime,nosuid,nodiratime
        - dump: 0
        - pass_num: 0
        - persist: True
        - require:
            - file: data-mount
    {% endif %}

# vim: syntax=yaml
