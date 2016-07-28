
# python dev packages

python-dev-packages:
    pkg.installed:
        - pkgs:
            - python2.7-dev
            - python3-dev
            - libcurl4-openssl-dev
            - libapt-pkg-dev
            - python-apt-dev
            - libjpeg62-turbo-dev
            - libfreetype6-dev
            - libxslt1-dev
            - libxml2-dev
            - libgd2-xpm-dev
        - install_recommends: False
        - require:
            - pkg: build-essential


python-dev-backports:
    pkg.installed:
        - pkgs:
            - libssl-dev
        - order: 20  # see ORDER.md
        - install_recommends: False
        - fromrepo: jessie-backports
        - require:
            - pkg: build-essential
