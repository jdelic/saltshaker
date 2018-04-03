apache2:
    webdav:
        enabled: True
        sites:
            - webdav.maurusnet.test:
                authrealm: maurus.net webdav
                sslcert: default
                sslkey: default
                folders:
                    - vagrant:
                        required-scopes:
                            - webdav-storage
