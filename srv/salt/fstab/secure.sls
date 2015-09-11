
secure-mount: 
    {% if grains['envdir']['secure'] is defined %} 
        mount.mounted:
            - name: /secure
            - device: {{grains['envdir']['secure']['device']}}
            - fstype: ext4
            - opts: data=journal,defaults,noauto,noatime,nosuid,nodiratime
            - dump: 0
            - pass_num: 0
            - persist: True
            - mkmnt: True
        file.directory:
            - name: /secure
            - user: root
            - group: root
            - mode: '0755'
            - require:
                - mount: secure-mount
    {% else %}
        file.directory:
            - name: /secure
            - makedirs: True
            - user: root
            - group: root
            - mode: '0755'
    {% endif %}

# vim: syntax=yaml

