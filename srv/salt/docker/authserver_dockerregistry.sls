#
# This state sets up Docker Token auth for the Docker registry on a server with the authserver role
#

{% if pillar.get('docker', {}).get('registry', {}).get('enabled', False) %}
#FIXME: support new authserver commands and create JWT key correctly

{% set registry_hostname = pillar['docker']['registry']['hostname'] %}
docker-registry-domain:
    cmd.run:
        - name: >-
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ \
                /usr/local/authserver/bin/django-admin.py domain --settings=authserver.settings \
                    create --create-key jwt "{{registry_hostname}}"
        - unless: >-
            test $(/usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ \
                       /usr/local/authserver/bin/django-admin.py domain --settings=authserver.settings \
                           list --format=json --include-parent-domain {{registry_hostname}} | jq length) -gt 0

docker-registry-tokenauth:
    cmd.run:
        - name: >-
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ \
                /usr/local/authserver/bin/django-admin.py dockerauth --settings=authserver.settings \
                    registry create --name "Main Registry" --client-id "{{registry_hostname}}" \
                        --domain "{{registry_hostname}}"
        - unless: >-
            /usr/local/authserver/bin/envdir /etc/appconfig/authserver/env/ \
                /usr/local/authserver/bin/django-admin.py dockerauth --settings=authserver.settings \
                    registry list | grep -q "{{registry_hostname}}"
        - require:
            - cmd: docker-registry-domain
{% endif %}
