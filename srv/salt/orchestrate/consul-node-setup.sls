# runs on the master via reactor
{% set tag = salt.pillar.get('tag') %}
{% set data = salt.pillar.get('data') %}


consul-acl-policy-create:
    salt.runner:
        - name: salt.cmd
        - arg:
            - http.query
        - kwarg:
            url: http://169.254.1.1:8500/v1/acl/policy
            method: PUT
            header_dict:
                X-Consul-Token: {{salt['dynamicsecrets'].get_store().load('consul-acl-master-token', host="*")}}
            data: >-
                {
                    "Name": "policy-{{data['id']|replace('.', '-')}}",
                    "Description": "Agent policy for {{data['id']}}",
                    "Rules": "{{"
                        key_prefix \"\" {
                            policy = \"deny\"
                        }

                        key_prefix \"oauth2-clients\" {
                            policy = \"write\"
                        }

                        key_prefix \"concourse/workers/sshpub\" {
                            policy = \"write\"
                        }

                        node_prefix \"\" {
                            policy = \"read\"
                        }

                        node \""|replace('\n', '\\n')|replace('"', '\\"')}}{{data['id']}}{{"\" {
                            policy = \"write\"
                        }

                        service_prefix \"\" {
                            policy = \"write\"
                        }

                        agent \""|replace('\n', '\\n')|replace('"', '\\"')}}{{data['id']}}{{"\" {
                            policy = \"write\"
                        }

                        event_prefix \"\" {
                            policy = \"read\"
                        }

                        query_prefix \"\" {
                            policy = \"read\"
                        }
                    "|replace('\n', '\\n')|replace('"', '\\"')}}"
                }


# the token has previously been created by dynamicsecrets (the secret is declared
# as type="consul-acl-token"). So we can just update it with the new policy we just created
consul-acl-token-update:
    salt.runner:
        - name: salt.cmd
        - arg:
            - http.query
        - kwarg:
            url: http://169.254.1.1:8500/v1/acl/token/{{salt['dynamicsecrets'].get_store().load(
                  'consul-acl-token',
                  host=data['id'])['accessor_id']}}
            method: PUT
            header_dict:
                X-Consul-Token: {{salt['dynamicsecrets'].get_store().load('consul-acl-master-token', host="*")}}
            data: >-
                {
                    "Description": "token-{{data['id']}}",
                    "Policies": [
                        {
                            "Name": "policy-{{data['id']|replace('.', '-')}}"
                        }
                    ]
                }
        - require:
            - salt: consul-acl-policy-create


consul-acl-install:
    salt.state:
        - name: ACL installation
        - tgt: {{data['id']}}
        - sls:
            - consul.acl_install
            - consul.template_acl_install
        - require:
            - salt: consul-acl-token-update


# work around https://github.com/hashicorp/consul/issues/5651
consul-template-reload:
    salt.function:
        - name: service.reload
        - tgt: {{data['id']}}
        - arg:
            - consul-template
        - require:
            - salt: consul-acl-token-update
