#!pydsl
# vim: syntax=python


def create_user(username, groups=None, optional_groups=None, key_pillars=None, password=None,
                create_default_group=True, enable_byobu=True, set_bashrc=True):
    _groups = groups or []
    if create_default_group and username not in groups:
        _groups.insert(0, username)

    st_group = state("groups-%s" % username).group
    st_group.present(names=_groups)

    st_user = state(username).user
    st_user.require(st_group)

    st_user.present(
        groups=_groups,
        optional_groups=optional_groups,
        home='/home/%s' % username,
        password=password,
        gid_from_name=create_default_group,
        shell="/bin/bash"
    )

    names = []
    for k in key_pillars:
        if k in __pillar__['sshkeys']:
            names.append(__pillar__['sshkeys'][k])

    if len(names) > 0:
        fn_auth = state(username).ssh_auth.present
        fn_auth.require(st_user)
        fn_auth(user=username, names=names)

    if enable_byobu:
        st_byobu = state('byobu-%s' % username).cmd.run
        st_byobu.require(pkg='byobu')
        st_byobu(
            name='/usr/bin/byobu-launcher-install',
            runas=username,
            unless='grep -q byobu /home/%s/.profile' % username
        )

        st_byobu_tmux_config = state('byobu-%s-tmux-config' % username).file
        sbcm = st_byobu_tmux_config.managed(
            '/home/%s/.byobu/.tmux.conf' % username,
            source='salt://mn/users/tmux-user.conf',
            user=username,
            group=username,
            mode='644'
        )
        sbcm.require(cmd='byobu-%s' % username)

        st_byobu_status_config = state('byobu-%s-status-config' % username).file
        sbsc = st_byobu_status_config.managed(
            '/home/%s/.byobu/status' % username,
            source='salt://mn/users/status',
            user=username,
            group=username,
            mode='644'
        )
        sbsc.require(cmd='byobu-%s' % username)

    if set_bashrc:
        file_bashrc = state('/home/%s/.bashrc' % username).file
        file_bashrc.require(st_user)
        file_bashrc.managed(
            source='salt://mn/users/bashrc',
            user=username,
            group=username,
            mode='640'
        )

