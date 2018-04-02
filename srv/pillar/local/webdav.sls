apache2:
    webdav:
        scopes:
            - webdav-storage
        sites:
            - webdav.maurusnet.test:
                authrealm: maurus.net webdav
                sslcert: default
                sslkey: default
                folders:
                    - vagrant:
                        required-scopes:
                            - webdav-storage
