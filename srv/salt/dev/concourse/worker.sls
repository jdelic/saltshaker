
include:
    - consul.sync
    - powerdns.sync
    - dev.concourse.install


concourse-keys-worker_key-public:
    file.managed:
        - name: /etc/concourse/private/worker_key.pem.pub
        - contents_pillar: dynamicsecrets:concourse-workerkey:public
        - user: concourse
        - group: concourse
        - mode: '0644'
        - replace: True
        - require:
            - user: concourse-user
            - file: concourse-private-config-folder


concourse-keys-worker_key:
    file.managed:
        - name: /etc/concourse/private/worker_key.pem
        - contents_pillar: dynamicsecrets:concourse-workerkey:key
        - user: concourse
        - group: concourse
        - mode: '0600'
        - replace: True
        - require:
            - file: concourse-keys-worker_key-public
            - user: concourse-user


# register the worker for the server
concourse-worker_key-consul-submit:
    cmd.run:
        - name: consul kv put concourse/workers/sshpub/{{grains['id']}} @/etc/concourse/private/worker_key.pem.pub
        - onchanges:
            - file: concourse-keys-worker_key-public
        - require:
            - file: concourse-keys-worker_key
            - cmd: consul-sync


concourse-worker-dir:
    file.directory:
        - name: /srv/concourse-worker/
        - user: concourse
        - group: concourse
        - mode: '0755'
        - require:
            - user: concourse-user


concourse-worker-envvars:
    file.managed:
        - name: /etc/concourse/envvars-worker
        - user: root
        - group: root
        - mode: '0600'
        - contents: |
            CONCOURSE_GARDEN_NETWORK_POOL="{{pillar.get('ci', {}).get('garden-network-pool', '10.254.0.0/22')}}"
            CONCOURSE_GARDEN_DOCKER_REGISTRY="{{pillar.get('ci', {}).get('garden-docker-registry',
              'registry-1.docker.io')}}"
            CONCOURSE_GARDEN_DNS_SERVER=169.254.1.1
            CONCOURSE_GARDEN_DESTROY_CONTAINERS_ON_STARTUP=1


concourse-worker:
    systemdunit.managed:
        - name: /etc/systemd/system/concourse-worker.service
        - source: salt://dev/concourse/concourse.jinja.service
        - template: jinja
        - user: root
        - group: root
        - context:
            type: worker
            user: root  # worker must be run as root as it orchestrates containers (see concourse CI docs)
            group: root
            # tsa-host on 127.0.0.1 works because there is haproxy@internal proxying it
            arguments: >
                --work-dir /srv/concourse-worker
                --bind-ip 127.0.0.1
                --bind-port 7777
                --tsa-host 127.0.0.1:{{pillar.get('concourse-server', {}).get('tsa-port', 2222)}}
                --tsa-public-key /etc/concourse/host_key.pub
                --tsa-worker-private-key /etc/concourse/private/worker_key.pem
            environment_files:
                - /etc/concourse/envvars-worker
        - require:
            - file: concourse-install
            - file: concourse-worker-dir
            - cmd: concourse-worker_key-consul-submit
    service.running:
        - name: concourse-worker
        - sig: /usr/local/bin/concourse_linux_amd64 worker
        - enable: True
        - require:
            - cmd: powerdns-sync
        - watch:
            - systemdunit: concourse-worker
            - file: concourse-install  # restart on a change of the binary
            - file: concourse-worker-envvars


# allow forwarding of outgoing dns/http/https traffic to the internet from concourse.ci/garden containers
{% for port in ['53', '80', '443', '8100'] %}
concourse-worker-tcp-out{{port}}-forward:
    iptables.append:
        - table: filter
        - chain: FORWARD
        - jump: ACCEPT
        - source: {{pillar.get('ci', {}).get('garden-network-pool', '10.254.0.0/22')}}
        - destination: 0/0
        - dport: {{port}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables
{% endfor %}


# allow incoming connections from concourse TSA. Outgoing connections for the web/server node are
# covered by basics.sls for the internal network
{% for port in ['7777', '7788', '7799'] %}
concourse-worker-tcp-in{{port}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - in-interface: {{pillar['ifassign']['internal']}}
        - dport: {{port}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables
{% endfor %}


concourse-worker-udp-out53-forward:
    iptables.append:
        - table: filter
        - chain: FORWARD
        - jump: ACCEPT
        - source: {{pillar.get('ci', {}).get('garden-network-pool', '10.254.0.0/22')}}
        - destination: 0/0
        - dport: 53
        - match: state
        - connstate: NEW
        - proto: udp
        - save: True
        - require:
            - sls: iptables


concourse-allow-inter-container-traffic-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: {{pillar.get('ci', {}).get('garden-network-pool', '10.254.0.0/22')}}
        - destination: {{pillar.get('ci', {}).get('garden-network-pool', '10.254.0.0/22')}}
        - save: True
        - require:
            - sls: iptables


concourse-allow-inter-container-traffic-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - source: {{pillar.get('ci', {}).get('garden-network-pool', '10.254.0.0/22')}}
        - destination: {{pillar.get('ci', {}).get('garden-network-pool', '10.254.0.0/22')}}
        - save: True
        - require:
            - sls: iptables

# vim: syntax=yaml
