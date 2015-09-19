#
# BASICS is really a collection of state pulled together through the "include" statement at the top of this file
# which installs a common baseline for servers configured with the maurus.net saltshaker project. Instead of
# assigning said states individually, you should really just assign "basics" to a node.
#


# Some of the states in this file enforce special ordering to make sure that the firewall is configured to allow
# access to the saltmaster before other states are executed that require such access. Notably iptables.init reserves
# order 1, 2 and 3 for the netfilter baseline setup so we can make sure that rules are added in a certain order.

include:
    - vim
    - etc_mods
    - salt-minion
    - python
    - python.apt
    - iptables  # forces "order: 1"
    - ssl

less:
    pkg.installed


coreutils:
    pkg.installed


patch:
    pkg.installed


dnsutils:
    pkg.installed


backports-org-jessie:
    pkgrepo.managed:
        - humanname: Jessie Backports
        - name: deb http://ftp-stud.hs-esslingen.de/debian/ jessie-backports main
        - file: /etc/apt/sources.list.d/jessie-backports.list


openssl:
    pkg.installed:
        - pkgs:
             - openssl
             - openssl-blacklist
             - openssl-blacklist-extra

openssh:
    pkg.installed:
        - pkgs:
            - ssh
            - openssh-blacklist
            - openssh-blacklist-extra
            - openssh-server
            - openssh-client
            - libssh2-1


# always allow ssh in
openssh-in22-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - source: '0/0'
        - proto: tcp
        - dport: 22
        - match: state
        - connstate: NEW
        - require:
            - sls: iptables
        - order: 2


# NETWORK SERVICES ON THE INTERNET ===========================================
# ssh out, dns out, http out, ntp out, https out
# pgp keyserver hkp out
# Note: Consul is installed on all machines so it's covered by consul.install
{%- set tcp = ['22', '53', '80', '123', '443', '11371'] %}

# dns out, ntp out
{%- set udp = ['53', '123'] %}

{% for port in tcp %}
# allow us to contact others on ports
basics-tcp-out{{port}}-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - destination: '0/0'
        - dport: {{port}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - order: 2
{% endfor %}


{% for port in udp %}
# allow us to call others
basics-udp-out{{port}}-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - proto: udp
        - dport: {{port}}
        - save: True
        - order: 2


# allow others to answer. For UDP we make this stateless here to guarantee it works.
basics-udp-out{{port}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - proto: udp
        - sport: {{port}}
        - save: True
        - order: 2
{% endfor %}


# OPEN THE INTERNAL NETWORK FOR OUTGOING CONNECTIONS =========================
basics-internal-network-tcp:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - out-interface: {{pillar['ifassign']['internal']}}
        - match: state
        - connstate: NEW
        - proto: tcp
        - save: True
        - require:
            - sls: iptables


basics-internal-network-udp:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - out-interface: {{pillar['ifassign']['internal']}}
        - proto: udp
        - save: True
        - require:
            - sls: iptables


# vim: syntax=yaml
