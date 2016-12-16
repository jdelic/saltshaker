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
    - crypto


# enforce that Debian packages can't launch daemons while salt runs
# see http://people.debian.org/~hmh/invokerc.d-policyrc.d-specification.txt
policy-deny:
    file.managed:
        - name: /usr/sbin/policy-rc.d
        - source: salt://policy-rc.d
        - mode: 0755
        - user: root
        - group: root
        - order: 1  # execute super-early before we install most packages


# at the end we remove the policy-rc.d file again to restore default behavior...
# it might be worthwhile to switch all Debian boxes to a default policy of "deny"
# and remove this state.
policy-allow:
    file.absent:
        - name: /usr/sbin/policy-rc.d
        - order: last  # remove the file when we're basically done


basic-required-packages:
    pkg.installed:
        - pkgs:
            - less
            - bash-completion
            - coreutils
            - patch
            - dnsutils
            - unzip
            - python-psutil  # required by salt's process.absent state
        -  order: 1  # execute this state early, because later states need unzip


jessie:
    pkgrepo.managed:
        - humanname: Jessie Base
        - name: {{pillar['repos']['jessie']}}
        - file: /etc/apt/sources.list
        {% if pillar['repos'].get('pgpkey', None) %}
        - key_url: {{pillar['repos']['pgpkey']}}
        {% endif %}
        - consolidate: True
        - order: 1  # execute this state early!


updates-jessie:
    pkgrepo.managed:
        - humanname: Jessie Updates
        - name: {{pillar['repos']['jessie-updates']}}
        - file: /etc/apt/sources.list.d/jessie-updates.list
        - order: 2  # execute this state early!


security-updates-jessie:
    pkgrepo.managed:
        - humanname: Jessie Security Updates
        - name: {{pillar['repos']['jessie-security']}}
        - file: /etc/apt/sources.list.d/jessie-security.list
        - order: 2  # execute this state early!


backports-org-jessie:
    pkgrepo.managed:
        - humanname: Jessie Backports
        - name: {{pillar['repos']['jessie-backports']}}
        - file: /etc/apt/sources.list.d/jessie-backports.list
        - order: 2  # execute this state early!
    file.managed:
        - name: /etc/apt/preferences.d/jessie-backports
        - source: salt://etc_mods/jessie-backports


maurusnet-repo:
    pkgrepo.managed:
        - humanname: repo.maurus.net
        - name: {{pillar['repos']['maurusnet']}}
        - file: /etc/apt/sources.list.d/maurusnet.list
        - key_url: salt://mn/packaging_authority_A78049AF.pgp.key
        - order: 2  # execute this state early!


maurusnet-opensmtpd:
    pkgrepo.managed:
        - humanname: repo.maurus.net-opensmtpd
        - name: {{pillar['repos']['maurusnet-opensmtpd']}}
        - file: /etc/apt/sources.list.d/opensmtpd.list
        - key_url: salt://mn/packaging_authority_A78049AF.pgp.key
        - order: 2


openssl:
    # this will upgrade the installed version from the basebox, because we currently must to have
    # compatible versions
    pkg.latest:
        - pkgs:
             - openssl
             - openssl-blacklist
             - openssl-blacklist-extra
             - libssl1.0.0
        - install_recommends: False
        - order: 10  # see ORDER.md
        - fromrepo: jessie-backports
        - require:
            - pkgrepo: backports-org-jessie


stretch:
    pkgrepo.managed:
        - humanname: Stretch Debian Testing
        - name: {{pillar['repos']['stretch-testing']}}
        - file: /etc/apt/sources.list.d/stretch-testing.list
        - order: 2
    file.managed:
        - name: /etc/apt/preferences.d/stretch-testing
        - source: salt://opensmtpd/preferences.d/stretch-testing


openssh:
    pkg.installed:
        - pkgs:
            - ssh
            - openssh-blacklist
            - openssh-blacklist-extra
            - openssh-server
            - openssh-client
            - libssh2-1
        - install_recommends: False


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
        - save: True
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
