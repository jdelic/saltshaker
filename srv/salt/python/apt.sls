#
# BASICS: python.apt is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#

# install python-apt, a dependency for the pkgrepo state
# that is otherwise missing from the salt-minion dependency list ...

python-apt-packages:
    pkg.installed:
        - pkgs:
            - python-apt
            - debconf-utils
            - python-pycurl
