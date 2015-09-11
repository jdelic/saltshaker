
# Debian's daemontools package has come a long way
# so let's use that

daemontools:
    pkg.installed:
        - pkgs:
            - daemontools
            - daemontools-run
        - require:
            - file: /var/log/svscan


/var/log/svscan:
    file.directory:
        - mode: 755
        - user: root
        - group: root
        

/usr/bin/svscanboot:
    file.managed:
        - source: salt://djb/svscanboot.override
        - mode: 755
        - user: root
        - group: root
        - require:
            - pkg: daemontools


svscanboot-restart:
    cmd.wait:
        - name: kill $(pgrep svscanboot) $(pgrep svscan) $(pgrep readproctitle)
        - watch:
            - file: /usr/bin/svscanboot
        - onlyif: pgrep readproctitle


# -* vim: syntax=yaml