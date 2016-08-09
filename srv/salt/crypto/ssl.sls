#
# BASICS: crypto is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#

ssl-cert:
    group.present


ssl-cert-location:
    file.directory:
        - name: {{pillar['ssl']['certificate-location']}}
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True


ssl-key-location:
    file.directory:
        - name: {{pillar['ssl']['secret-key-location']}}
        - user: root
        - group: ssl-cert
        - mode: '0710'
        - makedirs: True


# install private certificates if they have been assigned to this node in the pillars
{% if 'ssl' in pillar and 'maincert' in pillar['ssl'] %}
ssl-maincert-combined-certificate:
    file.managed:
        - name: {{pillar['ssl']['default-cert-combined']}}
        - contents_pillar: ssl:maincert:combined
        - user: root
        - group: root
        - mode: '0444'
        - require:
            - file: ssl-cert-location


ssl-maincert-key:
    file.managed:
        - name: {{pillar['ssl']['default-cert-key']}}
        - contents_pillar: ssl:maincert:key
        - user: root
        - group: ssl-cert
        - mode: '0440'
        - require:
            - file: ssl-key-location


ssl-maincert-combined-key:
    file.managed:
        - name: {{pillar['ssl']['default-cert-full']}}
        - contents_pillar: ssl:maincert:combined-key
        - user: root
        - group: ssl-cert
        - mode: '0440'
        - require:
            - file: ssl-key-location


ssl-maincert:
    file.managed:
        - name: {{pillar['ssl']['default-cert']}}
        - contents_pillar: ssl:maincert:cert
        - user: root
        - group: root
        - mode: '0444'
        - require:
            - file: ssl-maincert-combined-certificate
            - file: ssl-maincert-key
            - file: ssl-maincert-combined-key
{% endif %}


localca-location:
    file.directory:
        - name: /usr/share/ca-certificates/local/
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True


maurusnet-ca-root-certificate:
    file.managed:
        - name: /usr/share/ca-certificates/local/maurusnet-rootca.crt
        - source: salt://crypto/maurusnet-rootca.crt
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - file: localca-location


maurusnet-ca-intermediate-certificate:
    file.managed:
            - name: /usr/share/ca-certificates/local/maurusnet-minionca.crt
            - source: salt://crypto/maurusnet-minionca.crt
            - user: root
            - group: root
            - mode: '0644'
            - require:
                - file: localca-location


add-maurusnet-ca-certificates:
    file.append:
        - name: /etc/ca-certificates.conf
        - text: |
            local/maurusnet-minionca.crt
            local/maurusnet-rootca.crt
        - require:
            - file: maurusnet-ca-intermediate-certificate
            - file: maurusnet-ca-root-certificate
    cmd.wait:
        - name: /usr/sbin/update-ca-certificates
        - watch:
            - file: add-maurusnet-ca-certificates


# vim: syntax=yaml
