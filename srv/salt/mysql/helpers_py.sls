#!pydsl
# vim: syntax=python
import os

def add_mysql_instance(
            name,
            prefix=None,
            number=None,
            ip=None,
            port=None,
            datadir=None,
            user='mysql',
            group='mysql',
            require_mount=None
        ):
    # run and enable the mysqld instance. The config states defined below insert themselves as a required_in
    # dependency into this state and then the hardening states that require to log into the instance depend on
    # this service state so they can log in after it runs.
    service_state_name = 'mysql-service-%s' % prefix
    st_service = state(service_state_name)
    st_svc_r = st_service.service.running
    st_svc_r(
        name='mysql@%s' % number,
        # salt.state.service calls salt.modules.debian_service which calls salt.modules.status.pid which uses
        # the `sig` parameter as a regex, so the line below should match processes that have mysqld and the
        # prefix in their command-line
        sig='mysqld.*%s' % prefix,
        enable=True,
    )
    st_svc_r.require(file='mysql-multi')

    service_template_context = {
        'number': number,
        'prefix': prefix,
        'ip': ip,
        'port': port,
        'datadir': datadir,
        'user': user,
    }

    # create the mysqld-multi config file
    st_config = state('mysql-config-%s' % prefix)
    st_c_tpl = st_config.file.managed
    st_c_tpl(
        name='/etc/mysql/conf.d/%s.cnf' % prefix,
        source='salt://mysql/mysqldN.jinja.cnf',
        user='mysql',
        gourp='mysql',
        template='jinja',
        context=service_template_context,
    )
    st_c_tpl.require(pkg='mysql-server')
    st_c_tpl.require(file='mysql-datadir-%s' % prefix)
    # make mysql-multi restart when the config file is deployed
    st_c_tpl.watch_in(service=service_state_name)
    st_c_tpl.require_in(service=service_state_name)

    st_data = state('mysql-datadir-%s' % prefix)
    # create the db base folder
    st_d_fd = st_data.file.directory
    st_d_fd(
        name=datadir,
        user=user,
        group=group,
        mode='0750'
    )
    st_d_fd.require(pkg='mysql-server')

    if require_mount:
        st_d_fd.require(file=require_mount)

    # initialize the db
    st_d_cr = st_data.cmd.run
    st_d_cr(
        name='/usr/bin/mysql_install_db --datadir=%s --user=%s --defaults-file=/etc/mysql/my.cnf --defaults-extra-file=/etc/mysql/conf.d/%s.cnf' % (datadir, user, prefix,),
        unless='test -e %s' % os.path.join(datadir, 'mysql'),
    )
    st_d_cr.require(pkg='mysql-server')
    st_d_cr.require(file='mysql-datadir-%s' % prefix)
    st_d_cr.require(file='mysql-config-%s' % prefix)
    st_d_cr.require_in(service=service_state_name)

    # create a mysql root user
    st_root = state('mysql-root-%s' % prefix)
    st_r_u = st_root.mysql_user.present
    st_r_u(
        name='root',
        password=__pillar__['dynamicpasswords']['mysql-root'],
        connection_default_file='/etc/mysql/conf.d/%s.cnf' % prefix,
        connection_user='root',
        connection_pass='',
        onlyif='sleep 1',
    )
    st_r_u.require(service=service_state_name)

    # create a mysql maintenance user
    st_debiansys = state('debian-sys-maint-%s' % prefix)
    st_d_sg = st_debiansys.mysql_grants.present
    st_d_sg(
        name='debian-sys-maint',
        grant='all privileges',
        database='*.*',
        user='debian-sys-maint',
        grant_option=True,
        connection_default_file='/etc/mysql/conf.d/%s.cnf' % prefix,
        connection_user='root',
        connection_pass=__pillar__['dynamicpasswords']['mysql-root'],
    )
    st_d_sg.require(service=service_state_name)
    st_d_sg.require(mysql_user='debian-sys-maint-%s' % prefix)

    st_d_u = st_debiansys.mysql_user.present
    st_d_u(
        name='debian-sys-maint',
        password=__pillar__['dynamicpasswords']['debian-sys-maint'],
        connection_default_file='/etc/mysql/conf.d/%s.cnf' % prefix,
        connection_user='root',
        connection_pass=__pillar__['dynamicpasswords']['mysql-root'],
    )
    st_d_u.require(service=service_state_name)
    st_d_u.require(mysql_user='mysql-root-%s' % prefix)

    # harden the db
    st_harden = state('mysql-harden-%s' % prefix)
    st_h_cw = st_harden.cmd.wait_script
    st_h_cw(
        name='/tmp/mysql_secure_installation_auto %s %s /etc/mysql/conf.d/%s.cnf' % (
            __pillar__['dynamicpasswords']['mysql-root'],
            __pillar__['dynamicpasswords']['debian-sys-maint'],
            prefix,
        ),
        source='salt://mysql/mysql_secure_installation_auto',
        cwd='/tmp',
        user='root',
        group='root',
    )
    st_h_cw.watch(cmd='mysql-datadir-%s' % prefix)
    st_h_cw.require(file='mysql-config-%s' % prefix)
    st_h_cw.require(mysql_grants='debian-sys-maint-%s' % prefix)
    st_h_cw.require(mysql_user='mysql-root-%s' % prefix)

    consul_servicedef = state('mysql-%s-consul-servicedef' % prefix)
    c_sdef = consul_servicedef.file.managed
    c_sdef(
        name='/etc/consul.d/mysql-%s.json' % prefix,
        source='salt://mysql/consul/mysql.jinja.json',
        mode='0644',
        template='jinja',
        context=service_template_context,
    )
    c_sdef.require(file='consul-service-dir')
