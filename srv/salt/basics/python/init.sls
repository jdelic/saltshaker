#
# BASICS: python.init is included by basics (which are installed as a baseline everywhere)
# Usually, you won't need to assign this state manually. Assign "basics" instead.
#

# make sure that python is always installed

python-packages:
    pkg.installed:
        - pkgs:
            - python-is-python3
            - python3
            - python3-pip
            - python3-docker
            - python3-jinja2
            - python3-setuptools
            - python3-pkg-resources
            - python3-pip-whl
            - python3-virtualenv
            - virtualenv
            - gettext
            - libjpeg62-turbo
            - libxml2
            - libxslt1.1
            - libfreetype6
            - libgd3
            - python3-distlib
        - install_recommends: False
