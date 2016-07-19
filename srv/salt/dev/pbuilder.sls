
pbuilder:
    pkg.installed:
        - install_recommends: False


pbuilder-uml:
    pkg.installed:
        - pkgs:
            - pbuilder-uml
            - rootstrap
            - uml-utilities
            - user-mode-linux
            - slirp
            - fakeroot
        - install_recommends: False


# TODO: download build chroot from Amazon S3

# vim: syntax=yaml
