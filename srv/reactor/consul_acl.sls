consul_acl_create:
    runner.salt.cmd:
        - args:
            - fun: http.query
            - url: http://169.254.1.1:8500/v1/acl/create
            - method: PUT
            - header_dict:
                X-Consul-Token: {{salt['dynamicsecrets'].get_store().load('consul-acl-master-token', host="*")}}
            - data: >-
                {
                    "ID": "{{salt['dynamicsecrets'].get_store().get_or_create(
                                {
                                    "type": "uuid",
                                },
                                'consul-acl-token',
                                host=data['id'])}}",
                    "Name": "{{data['id']}}",
                    "Rules": "{{"
                        key \"\" {
                            policy = \"deny\"
                        }

                        key \"oauth2-clients\" {
                            policy = \"write\"
                        }

                        key \"concourse/workers/sshpub\" {
                            policy = \"write\"
                        }

                        node \"\" {
                            policy = \"read\"
                        }

                        node \""|replace('\n', '')|replace('"', '\\"')}}{{data['id']}}{{"\" {
                            policy = \"write\"
                        }

                        service \"\" {
                            policy = \"write\"
                        }
                    "|replace('\n', '')|replace('"', '\\"')}}"
                }
