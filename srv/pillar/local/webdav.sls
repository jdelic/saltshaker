apache2:
    webdav:
        sites:
            common:
                hostname: webdav.maurusnet.test
                folders:
                    vagrant:
                        required-app-permissions:
                            - common-webdav
