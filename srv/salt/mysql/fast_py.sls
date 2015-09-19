#!pydsl

install = include("mysql.install")

helpers = include('mysql.helpers_py')
helpers.add_mysql_instance(
    'mysql-fast',
    prefix='fast',
    number=1,
    ip=__pillar__.get('mysql-fast', {}).get('ip', __grains__['ip_interfaces'][__pillar__['ifassign']['internal']][int(__pillar__['ifassign'].get('internal-ip-index', 0))]),
    port=3306,
    datadir='/data/mysql',
    root_password_pillar="mysql-root",
    require_mount='data-mount',
)


# allow others to contact us on port 3306
inp = state('mysql-in3306-recv').iptables.append
inp(
    table='filter',
    chain='INPUT',
    jump='ACCEPT',
    proto='tcp',
    i=__pillar__['ifassign']['internal'],
    dport='3306',
    match='state',
    connstate='NEW',
    save=True,
)
inp.require(sls='iptables')


# vim: syntax=python
