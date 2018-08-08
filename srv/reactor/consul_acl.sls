consul_acl_create:
    runner.salt.cmd:
        - args:
            - fun: consul.acl_create
            - args:
                - id: {{salt['dynamicsecrets'].get_store().load("consul-acl-token", host=data['id'])}}
                - name: {{data['id']}}
                - type: client
                - rules: >-
                    key "" {
                        policy = "deny"
                    }

                    key "oauth2-clients" {
                        policy = "write"
                    }

                    key "concourse/workers/sshpub" {
                        policy = "write"
                    }

                    node "" {
                        policy = "read"
                    }

                    node "{{data['id']}}" {
                        policy = "write"
                    }

                    service "" {
                        policy = "write"
                    }
