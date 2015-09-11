

dnscache-service-link:
    file.symlink:
        - target: /etc/dnscache
        - name: /etc/service/dnscache
        - require:
            - cmd: dnscache-install


tinydns-service-link:
    file.symlink:
        - target: /etc/tinydns-internal
        - name: /etc/service/tinydns-internal
        - require:
            - cmd: tinydns-install


tinydns-restart:
    cmd.wait:
        - name: svc -t /etc/service/tinydns-internal
        - watch:
            - cmd: tinydns-data-rebuild
        - onlyif: test -e /etc/tinydns-internal/root/data.cdb


tinydns-data-rebuild:
    cmd.wait:
        - name: make -f Makefile
        - cwd: /etc/tinydns-internal/root
        - watch:
            - file: tinydns-data

dnscache-restart:
    cmd.wait:
        - name: svc -t /etc/service/dnscache
        - watch:
            - file: dnscache-config


# vim: syntax=yaml

