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


ssl-combined-location:
    file.directory:
        - name: {{pillar['ssl']['combined-location']}}
        - user: root
        - group: root
        - mode: '0755'
        - makedirs: True


{% set ssl_material = {
    'cert': {'directory_state': 'ssl-cert-location', 'user': 'root', 'group': 'root', 'mode': '0444'},
    'chain': {'directory_state': 'ssl-combined-location', 'user': 'root', 'group': 'root', 'mode': '0444'},
    'key': {'directory_state': 'ssl-key-location', 'user': 'root', 'group': 'ssl-cert', 'mode': '0440'},
    'full': {'directory_state': 'ssl-key-location', 'user': 'root', 'group': 'ssl-cert', 'mode': '0440'},
} %}

# install private certificates if they have been assigned to this node in the pillars
{% for cert_name, cert_sources in pillar.get('ssl', {}).get('sources', {}).items() %}
    {% set cert_filenames = pillar.get('ssl', {}).get('filenames', {}).get(cert_name, {}) %}
    {% set cert_id = cert_name|replace('.', '-')|replace('_', '-')|replace(':', '-')|replace('/', '-') %}
    {% for material, material_config in ssl_material.items() %}
        {% set source_pillar = cert_sources.get(material) %}
        {% set target_file = cert_filenames.get(material) %}
        {% if source_pillar and target_file and salt['pillar.fetch'](source_pillar, None) %}
ssl-certificate-{{cert_id}}-{{material}}:
    file.managed:
        - name: {{target_file}}
        - contents_pillar: {{source_pillar}}
        - user: {{material_config['user']}}
        - group: {{material_config['group']}}
        - mode: '{{material_config['mode']}}'
        - require:
            - file: {{material_config['directory_state']}}
        {% endif %}
    {% endfor %}
{% endfor %}


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
