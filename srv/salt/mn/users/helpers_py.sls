#!pydsl
# vim: syntax=python

_sshkeys = {
    'vagrant': 'AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key',
    'symbiont_laptop': 'AAAAB3NzaC1yc2EAAAABJQAAAQBxrpUR4YVj5YoM+uzz325dx90peHDVwv270V1gec5SiaBYKebdmNWbokr3ljvh2VUkuOIP9VWfbqLVrtMpu+mfD61SZI7IuIgS1kr3BCDYI7Oz1zYD04yisECyGb3OLWcmx3ibyhFrOUCYCiKVk78Ou0bydld1rP8EkU4gH/AjBdEFgjYJ7ITxkVCWsrFMEidjmP7u5e6DXPKeeYSDVSXlALaW/65xDZck4Q38iNX3lN3/cKvaPtJL8yBQu83eO4IEwJ1Gui/zKU5qV61A1vc6eUPzZh/XyP/rmZYytQMbyT9uxZiH8dDAlm2/iq9ZJNFnYIAlDbRzegq9iDYGq547 jm laptop key',
    'symbiont_root': 'AAAAB3NzaC1yc2EAAAABJQAAAQEAjKMpzQVOi7ttoJrPrSZtsXmy2gAnoxQH/2vL6bQESkNe3V9gQmOyi/8RSzo7C8dIxlKkldcotld4FskxZ4M8IrLWOreCd90PZ4cei43TdlAvvSnobEiKw5JoNeyCeogp3jrANiLPx8ht16cCOvHVkBMcGDr4WnOzbzbc08swWUNifNR+wOQjSi1HX1/jXaN/5MJJIIZDuj6tMRa0EWHgkZGupFvkmjhAM9VjKU80ju7roAXivhYKf6gOqHxQbR8ip1JY70jv6A298CMwL6W8LODsilYG70cbn20lobmRHTthfm+muX5ohcCicJtSfYySfbhMaHoHWMjKyzKEFN/i0Q== symbiont root',
}


def create_user(username, groups=None, optional_groups=None, keys=None, password=None,
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
        gid_from_name=create_default_group
    )

    names = []
    for k in keys:
        if k in _sshkeys:
            names.append(_sshkeys[k])

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

        st_byobu_config = state('byobu-%s-config' % username).file
        sbcm = st_byobu_config.managed(
            '/home/%s/.byobu/.tmux.conf' % username,
            source='salt://mn/users/tmux-user.conf',
            user=username,
            group=username,
            mode='644'
        )
        sbcm.require(cmd='byobu-%s' % username)
        sbcm.watch(cmd='byobu-%s' % username)

    if set_bashrc:
        file_bashrc = state('/home/%s/.bashrc' % username).file
        file_bashrc.require(st_user)
        file_bashrc.managed(
            source='salt://mn/users/bashrc',
            user=username,
            group=username,
            mode='640'
        )

