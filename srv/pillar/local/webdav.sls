{% from salt['file.join'](tpldir, 'wellknown.sls') import external_tld %}

apache2:
    webdav:
        enabled: True

        # sites is a list of domain name configs
        sites:
            - webdav.{{external_tld}}:
                authrealm: {{external_tld}} webdav
                ssl-combined-cert: default
                folders:
                    - vagrant:
                        # A user who has a write scope can read and write to WebDav
                        write-scopes:
                            - webdav-storage
                        # A user who has a read scope can read from WebDav
                        # read-scopes:
                        #     - webdav-download
