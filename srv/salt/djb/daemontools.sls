
# Debian's daemontools package has come a long way
# so let's use that

daemontools:
    pkg.installed:
        - pkgs:
            - daemontools
            - daemontools-run
        - require:
            - file: svscan-log-folder


svscan-log-folder:
    file.directory:
        - name: /var/log/svscan
        - mode: 755
        - user: root
        - group: root


svscanboot-script:
    file.managed:
        - name: /usr/bin/svscanboot
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
            - file: svscanboot-script
        - onlyif: pgrep readproctitle


# -* vim: syntax=yaml
