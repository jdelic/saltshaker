#!pydsl

install = include("mysql.install")

# create /secure/db subfolder because add_mysql_instance can't
# create it safely and still know that its mounted correctly
st_sec_db = state('mysql-secure-db-folder').file.directory
st_sec_db(
    name='/secure/db',
    user='root',
    group='root',
    mode='0755',
)
st_sec_db.require(file='secure-mount')


helpers = include('mysql.helpers_py')
helpers.add_mysql_instance(
    'mysql-secure',
    prefix='secure',
    number=2,
    ip=__pillar__.get('mysql-secure', {}).get('ip', __grains__['ip_interfaces'][__pillar__['ifassign']['internal']][int(__pillar__['ifassign'].get('internal-ip-index', 0))]),
    port=3307,
    datadir='/secure/db/mysql',
    require_mount='mysql-secure-db-folder',
)

# allow others to contact us on port 3307
inp = state('mysql-in3307-recv').iptables.append
inp(
    table='filter',
    chain='INPUT',
    jump='ACCEPT',
    proto='tcp',
    i=__pillar__['ifassign']['internal'],
    dport='3307',
    match='state',
    connstate='NEW',
    save=True,
)
inp.require(sls='iptables')


# vim: syntax=python
