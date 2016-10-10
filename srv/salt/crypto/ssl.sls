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
        - name: {{pillar['ssl']['localca-location']}}
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True


rootca-certificate:
    file.managed:
        - name: {{pillar['ssl']['rootca-cert']}}
        - source: {{pillar['ssl']['rootca-source']}}
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - file: localca-location


rootca-certificate-symlink:
    file.symlink:
        - name: {{salt['file.join'](pillar['ssl']['localca-links-location'],
                                    salt['file.basename'](pillar['ssl']['rootca-cert']))}}
        - target: {{pillar['ssl']['rootca-cert']}}
        - require:
            - file: rootca-certificate


maurusnet-ca-intermediate-certificate:
    file.managed:
        - name: {{salt['file.join'](pillar['ssl']['localca-location'], 'maurusnet-minionca.crt')}}
        - source: salt://crypto/maurusnet-minionca.crt
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - file: localca-location


maurusnet-ca-intermediate-certificate-symlink:
    file.symlink:
        - name: {{salt['file.join'](pillar['ssl']['localca-links-location'], 'maurusnet-minionca.crt')}}
        - target: {{salt['file.join'](pillar['ssl']['localca-location'], 'maurusnet-minionca.crt')}}
        - require:
            - file: maurusnet-ca-intermediate-certificate


add-maurusnet-ca-certificate:
    file.append:
        - name: /etc/ca-certificates.conf
        - text: |
            {{salt['file.join'](salt['file.basename'](pillar['ssl']['localca-location']), 'maurusnet-minionca.crt')}}
        - require:
            - file: maurusnet-ca-intermediate-certificate
        - onchanges_in:
            - cmd: recompile-ca-certificates


add-rootca-certificate:
    file.append:
        - name: /etc/ca-certificates.conf
        - text: |
            {{salt['file.join'](salt['file.basename'](pillar['ssl']['localca-location']),
                                salt['file.basename'](pillar['ssl']['rootca-cert']))}}
        - require:
            - file: rootca-certificate
        - onchanges_in:
            - cmd: recompile-ca-certificates


recompile-ca-certificates:
    cmd.run:
        - name: /usr/sbin/update-ca-certificates


# vim: syntax=yaml
