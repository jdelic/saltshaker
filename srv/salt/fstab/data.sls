
data-mount:
    {% if grains['envdir']['secure'] is defined %}
       mount.mounted:
            - name: /data
            - device: {{grains['envdir']['data']['device']}}
            - fstype: ext4
            - opts: data=journal,defaults,noauto,noatime,nosuid,nodiratime
            - dump: 0
            - pass_num: 0
            - persist: True
            - mkmnt: True
        file.directory:
            - name: /data
            - user: root
            - group: root
            - mode: '0755'
            - require:
                - mount: data-mount 
    {% else %}
        file.directory:
            - name: /data
            - user: root
            - group: root
            - mode: '0755'
    {% endif %}

# vim: syntax=yaml
