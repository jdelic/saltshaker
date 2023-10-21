
# python dev packages

python-dev-packages:
    pkg.installed:
        - pkgs:
            - python3-dev
            - libapt-pkg-dev
            - python-apt-dev
            - libjpeg62-turbo-dev
            - libfreetype6-dev
            - libxslt1-dev
            - libxml2-dev
            - libgd-dev
            - libffi-dev
            - libpq-dev
        - install_recommends: False
        - require:
            - pkg: build-essential


python-dev-backports:
    pkg.installed:
        - pkgs:
            - libssl-dev
            - libcurl4-openssl-dev
        - order: 10  # see ORDER.md
        - install_recommends: False
        - require:
            - pkg: build-essential
