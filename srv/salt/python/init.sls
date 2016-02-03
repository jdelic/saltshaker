#
# BASICS: python.init is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#

# make sure that python is always installed

python-packages:
    pkg.installed:
        - pkgs:
            - python2.7
            - python-pip
            - python-pip-whl
            - python-virtualenv
            - gettext
            - libjpeg62-turbo
            - libxml2
            - libxslt1.1
            - libfreetype6
            - libgd3
        - install_recommends: False
        # salt dependencies on Jessie lead to an installation error for python setuptools when installing to stable
        # so we install from jessie-backports
        - fromrepo: jessie-backports

