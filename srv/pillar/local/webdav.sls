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
                        write-scopes:
                            - webdav-storage
                        # readonly-scopes:
                        #     - webdav-download
