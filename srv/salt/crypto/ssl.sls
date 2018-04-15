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
{% if pillar.get('ssl', {}).get('sources', {}).get('default-cert', None) and
      salt['pillar.fetch'](pillar['ssl']['sources']['default-cert'], None) %}
ssl-maincert-combined-certificate:
    file.managed:
        - name: {{pillar['ssl']['filenames']['default-cert-combined']}}
        - contents_pillar: {{pillar['ssl']['sources']['default-cert-combined']}}
        - user: root
        - group: root
        - mode: '0444'
        - require:
            - file: ssl-cert-location


ssl-maincert-key:
    file.managed:
        - name: {{pillar['ssl']['filenames']['default-cert-key']}}
        - contents_pillar: {{pillar['ssl']['sources']['default-cert-key']}}
        - user: root
        - group: ssl-cert
        - mode: '0440'
        - require:
            - file: ssl-key-location


ssl-maincert-combined-key:
    file.managed:
        - name: {{pillar['ssl']['filenames']['default-cert-full']}}
        - contents_pillar: {{pillar['ssl']['sources']['default-cert-full']}}
        - user: root
        - group: ssl-cert
        - mode: '0440'
        - require:
            - file: ssl-key-location


ssl-maincert:
    file.managed:
        - name: {{pillar['ssl']['filenames']['default-cert']}}
        - contents_pillar: {{pillar['ssl']['sources']['default-cert']}}
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


{% for cert in pillar['ssl'].get('install-ca-certs', []) + pillar['ssl'].get('install-perenv-ca-certs', []) %}
install-certificates-{{salt['file.basename'](cert)}}:
    file.managed:
        - name: {{salt['file.join'](pillar['ssl']['localca-location'], salt['file.basename'](cert))}}
        - source: {{cert}}
        - user: root
        - group: root
        - mode: '0644'
        - require:
            - file: localca-location

symlink-certificates-{{salt['file.basename'](cert)}}:
    file.symlink:
        - name: {{salt['file.join'](pillar['ssl']['localca-links-location'],
                                    salt['file.basename'](cert))}}
        - target: {{salt['file.join'](pillar['ssl']['localca-location'], salt['file.basename'](cert))}}
        - require:
            - file: install-certificates-{{salt['file.basename'](cert)}}

add-certificate-{{salt['file.basename'](cert)}}:
    file.append:
        - name: /etc/ca-certificates.conf
        - text: {{salt['file.join'](
            salt['file.basename'](pillar['ssl']['localca-location']),
            salt['file.basename'](cert)
        )}}
        - require:
            - file: install-certificates-{{salt['file.basename'](cert)}}
        - onchanges_in:
            - cmd: require-ssl-certificates
{% endfor %}


require-ssl-certificates:
    cmd.run:
        - name: /usr/sbin/update-ca-certificates


# vim: syntax=yaml
