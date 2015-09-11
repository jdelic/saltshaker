
# python dev packages

python-dev-packages:
    pkg.installed:
        - pkgs:
            - python2.7-dev
            - libssl-dev
            - libcurl4-openssl-dev
            - libapt-pkg-dev
            - python-apt-dev
            - libjpeg62-turbo-dev
            - libfreetype6-dev
            - libxslt1-dev
            - libxml2-dev
            - libgd2-xpm-dev
        - require:
            - pkg: build-essential

