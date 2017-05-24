
secure-mount:
    file.directory:
        - name: /secure
        - makedirs: True
        - user: root
        - group: root
        - mode: '0755'
    {% if grains['envdir']['secure'] is defined %}
    mount.mounted:
        - name: /secure
        - device: {{grains['envdir']['secure']['device']}}
        - fstype: ext4
        - opts: data=journal,defaults,noatime,nosuid,nodiratime
        - dump: 0
        - pass_num: 0
        - persist: True
        - require:
            - file: secure-mount
    {% endif %}

# vim: syntax=yaml

