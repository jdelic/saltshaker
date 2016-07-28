#
# Creates a MySQL database for Hashicorp Vault (as a backend) and an associated user.
# This is *independent* from the Vault MySQL secret backend that allows services to get
# temporary MySQL access credentials.
#
# This state is meant to be run on a server with the "secure-database" role.
#

# TODO: Vault currently fails to initialize with InnoDB and utf-8 due to a "key size"
#       problem until https://github.com/hashicorp/vault/pull/522 ships.

{% if pillar['vault'].get('backend', '') == 'mysql' %}

# only create this if the MySQL backend is selected
vault-mysql:
    mysql_user.present:
        - name: {{pillar['vault']['mysql']['dbuser']}}
        - password: {{pillar['dynamicpasswords']['secure-vault']}}
        # FIXME: let iptables take care of limiting connectivity to the local network until I figure out how to
        #        calculate a MySQL network string (192.168.56.%) from an IP and a netmask inside Salt
        - host: '%'
        - connection_user: root
        - connection_pass: {{pillar['dynamicpasswords']['secure-mysql-root']}}

        # FIXME: either connect directly to the internal interface using the line below OR wait for consul-template
        #        ...localhost might not be available when this state runs otherwise. This might be an ideal use-case
        #        for a noop state in each database-style and the "use:" directive. I.e.
        #        "use: secure-mysql-local-connection" where "secure-mysql-local-connection" is built by helpers_py
        #        to have the correct connection_default_file etc.
        #        See https://github.com/saltstack/salt/issues/27227 and https://github.com/saltstack/salt/pull/27208
        # {{pillar.get('mysql-secure', {}).get('ip', grains['ip_interfaces'][pillar['ifassign']['internal']][pillar['ifassign'].get('internal-ip-index', 0)|int])}}

        - connection_default_file: /etc/mysql/conf.d/secure.cnf
        #- connection_host: localhost
        #- connection_port: 3307
        - require:
            - mysql_user: mysql-root-secure
    mysql_database.present:
        - name: vault
        - connection_user: root
        - connection_pass: {{pillar['dynamicpasswords']['secure-mysql-root']}}
        - connection_default_file: /etc/mysql/conf.d/secure.cnf
        #- connection_host: localhost
        #- connection_port: 3307
        - order: 20  # see ORDER.md
        - require:
            - mysql_user: mysql-root-secure
    mysql_grants.present:
        - name: vault
        - grant: 'all privileges'
        - database: '{{pillar['vault']['mysql']['dbname']}}.*'
        - user: {{pillar['vault']['mysql']['dbuser']}}
        - host: '%'
        - connection_user: root
        - connection_pass: {{pillar['dynamicpasswords']['secure-mysql-root']}}
        - connection_default_file: /etc/mysql/conf.d/secure.cnf
        #- connection_host: localhost
        #- connection_port: 3307
        - require:
            - mysql_user: vault-mysql
            - mysql_database: vault-mysql
            - mysql_user: mysql-root-secure

{% endif %}
