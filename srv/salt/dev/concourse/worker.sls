
include:
    - dev.concourse.install


concourse-keys-worker_key:
    cmd.run:
        - name: ssh-keygen -t rsa -f /etc/concourse/private/worker_key.pem -N ''
        - runas: concourse
        - creates:
            - /etc/concourse/private/worker_key.pem
            - /etc/concourse/private/worker_key.pem.pub
        - require:
            - file: concourse-private-config-folder
            - user: concourse-user
    file.managed:
        - name: /etc/concourse/private/worker_key.pem
        - user: concourse
        - group: concourse
        - mode: '0640'
        - replace: False
        - require:
            - cmd: concourse-keys-worker_key


# register the worker for the server
concourse-worker_key-consul-submit:
    cmd.run:
        - name: consul kv put concourse/workers/sshpub/{{grains['id']}} @/etc/concourse/private/worker_key.pem.pub
        - unless: consul kv get -keys concourse/workers/sshpub/{{grains['id']}} | grep "{{grains['id']}}" >/dev/null
        - require:
            - file: concourse-keys-worker_key


concourse-worker-dir:
    file.directory:
        - name: /srv/concourse-worker/
        - user: concourse
        - group: concourse
        - mode: '0755'
        - require:
            - user: concourse-user


concourse-worker:
    file.managed:
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
                --tsa-host 127.0.0.1:{{pillar.get('concourse-server', {}).get('tsa-port', 2222)}}
                --tsa-public-key /etc/concourse/host_key.pub
                --tsa-worker-private-key /etc/concourse/private/worker_key.pem
                --garden-network-pool {{pillar.get('ci', {}).get('garden-network-pool', '10.254.0.0/22')}}
                --garden-docker-registry {{pillar.get('ci', {}).get('garden-docker-registry', 'registry-1.docker.io')}}
                --garden-dns-server=169.254.1.1
        - require:
            - file: concourse-install
            - file: concourse-worker-dir
            - file: concourse-keys-worker_key
    service.running:
        - name: concourse-worker
        - sig: /usr/local/bin/concourse_linux_amd64 worker
        - enable: True
        - require:
            - file: concourse-worker
        - watch:
            - file: concourse-worker
            - file: concourse-install  # restart on a change of the binary


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
