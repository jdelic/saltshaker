#
# BASICS: vim is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#


vim:
    pkg.installed

vimrc:
    file.managed:
        - name: /etc/vim/vimrc.local
        - source: salt://vim/vimrc
        - require:
            - pkg: vim

# vim: syntax=yaml

