#
# Creates a MySQL database for Hashicorp Vault (as a backend) and an associated user.
# This is *independent* from the Vault MySQL secret backend that allows services to get
# temporary MySQL access credentials.
#
# This state is meant to be run on a server with the "secure-database" role.
#

{% if pillar['vault'].get('backend', 'mysql') == 'mysql' %}

# only create this if the MySQL backend is selected
vault-mysql:
    mysql_user.present:
        - name: {{pillar['vault']['mysql']['dbuser']}}
        - password: {{pillar['dynamicpasswords']['secure-vault']}}
        # FIXME: let iptables take care of limiting connectivity to the local network until I figure out how to
        #        calculate a MySQL network string (192.168.56.%) from an IP and a netmask inside Salt
        - host: '%'
        - connection_user: root
        - connection_pass: {{pillar['dynamicpasswords']['secure-root']}}
        - connection_host: localhost
        - connection_port: 3307
        - require:
            - mysql_user: mysql-root-secure
    mysql_database.present:
        - name: vault
        - connection_user: root
        - connection_pass: {{pillar['dynamicpasswords']['secure-root']}}
        - connection_host: localhost
        - connection_pass: 3307
        - require:
            - mysql_user: mysql-root-secure
    mysql_grants.present:
        - name: vault
        - grant: 'all privileges'
        - database: '{{pillar['vault']['mysql']['dbname']}}.*'
        - user: {{pillar['vault']['mysql']['dbuser']}}
        - connection_user: root
        - connection_pass: {{pillar['dynamicpasswords']['secure-root']}}
        - connection_host: localhost
        - connection_pass: 3307
        - require:
            - mysql_user: vault-mysql
            - mysql_database: vault-mysql
            - mysql_user: mysql-root-secure

{% endif %}
