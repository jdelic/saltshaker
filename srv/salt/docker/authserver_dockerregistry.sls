#
# This state sets up Docker Token auth for the Docker registry on a server with the authserver role
#

{% if pillar.get('docker', {}).get('registry', {}).get('enabled', False) %}
#FIXME: support new authserver commands and create JWT key correctly

{% set registry_hostname = pillar['docker']['registry']['hostname'] %}



docker-registry-tokenauth:
    cmd.run:
        - name: >-
            echo "$JWT_KEY" |
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ \
                /usr/local/authserver/bin/django-admin.py dockerauth --settings=authserver.settings \
                    registry add --name "Main Registry" --client-id "{{registry_hostname}}" --sign-key-pem -
        - unless: >-
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ \
                /usr/local/authserver/bin/django-admin.py dockerauth --settings=authserver.settings \
                    registry list | grep -q "{{registry_hostname}}"
        - env:
            JWT_KEY: |
                {{pillar['dynamicsecrets']['dockerauth-jwt-key']['key']|indent(16)}}

{% endif %}
