
# python dev packages

python-dev-packages:
    pkg.installed:
        - pkgs:
            - python2.7-dev
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
        - fromrepo: jessie-backports
        - require:
            - pkg: build-essential
            # we need to depend on this state otherwise libssl-dev from jessie will be incompatible with libssl1.0.0
            # from the basebox
            - pkg: openssl
            - pkgrepo: backports-org-jessie
