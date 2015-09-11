
mailqueue-mount:
    {% if grains['envdir']['mailqueue'] is defined %}
        mount.mounted:
            - name: /mailqueue
            - device: {{grains['envdir']['mailqueue']['device']}}
            - fstype: ext4
            - opts: sync,defaults,noauto,noatime,nosuid,nodiratime,noexec
            - dump: 0
            - pass_num: 0
            - persist: True
            - mkmnt: True
    {% endif %}

# vim: syntax=yaml

