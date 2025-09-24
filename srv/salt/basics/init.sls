#
# BASICS is really a collection of state pulled together through the "include" statement at the top of this file
# which installs a common baseline for servers configured with the maurus.net saltshaker project. Instead of
# assigning said states individually, you should really just assign "basics" to a node.
#


# Some of the states in this file enforce special ordering to make sure that the firewall is configured to allow
# access to the saltmaster before other states are executed that require such access. Notably basics.nftables.init
# reserves order 1 to 4 for the netfilter baseline setup so we can make sure that rules are added in a certain order.

include:
    - .vim
    - .etc_mods
    - .salt-minion
    - .python
    - .python.apt
    - .nftables  # forces "order: 1"
    - .crypto
    - .rsyslog
    - .nounup


check-our-assumptions:
    sanitycheck.check:
        - order: 1


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
            - bind9-dnsutils
            - unzip
            - net-tools
            - libcap2-bin
            - apt-transport-https
            - apt-transport-s3
            - cron
            - dbus
            - dbus-user-session
            - jq
            - curl
            - systemd-timesyncd
            - gpg
        -  order: 9  # execute this state early, because later states need unzip


empty-crontab:
    file.managed:
        - name: /etc/cron.d/00-ignore
        - contents: |
            # nothing to see here, this is just for salt


cron:
    service.running:
        - sig: /usr/sbin/cron
        - watch:
            - file: /etc/cron.d*


dbus:
    service.running


no-sourceslist:
    file.managed:
        - name: /etc/apt/sources.list
        - contents: ""
        - order: 1


trixie:
    pkgrepo.managed:
        - name: {{pillar['repos']['trixie']}}
        - file: /etc/apt/sources.list.d/trixie.list
        {% if pillar['repos'].get('pgpkey', None) %}
        - key_url: {{pillar['repos']['pgpkey']}}
        - aptkey: False
        {% endif %}
        - order: 1  # execute this state early!


updates-trixie:
    pkgrepo.managed:
        - name: {{pillar['repos']['trixie-updates']}}
        - file: /etc/apt/sources.list.d/trixie-updates.list
        - order: 1  # execute this state early!


security-updates-trixie:
    pkgrepo.managed:
        - name: {{pillar['repos']['trixie-security']}}
        - file: /etc/apt/sources.list.d/trixie-security.list
        - order: 1  # execute this state early!


backports-org-trixie:
    pkgrepo.managed:
        - name: {{pillar['repos']['trixie-backports']}}
        - file: /etc/apt/sources.list.d/trixie-backports.list
        - order: 1  # execute this state early!
    file.managed:
        - name: /etc/apt/preferences.d/trixie-backports
        - source: salt://basics/etc_mods/trixie-backports


saltstack-repo:
    pkgrepo.managed:
        - name: {{pillar['repos']['saltstack']}}
        - file: /etc/apt/sources.list.d/salt.list
        - key_url: salt://saltstack_64CBBC8173D76B3F.pgp.key
        #- key_url: salt://mn/packaging_authority_A78049AF.pgp.key
        - aptkey: False
        - order: 10  # execute this state early!


maurusnet-apps:
    pkgrepo.managed:
        - humanname: repo.maurus.net-apps
        - name: {{pillar['repos']['maurusnet']}}
        - file: /etc/apt/sources.list.d/maurusnet.list
        - key_url: salt://mn/packaging_authority_A78049AF.pgp.key
        - aptkey: False
        - order: 10


# enforce UTC
timezone-utc:
    cmd.run:
        - name: timedatectl set-timezone UTC
        - unless: test "$(readlink /etc/localtime)" = "/usr/share/zoneinfo/Etc/UTC"
        - require:
            - service: dbus


# enforce en_us.UTF8

# Ubuntu has removed this file again in bugs.launchpad.net/ubuntu/+source/systemd/+bug/2102028
# but Debian in Trixie still has it.
remove-locale-gen-dbus-restriction:
    file.absent:
        - name: /usr/share/dbus-1/system.d/systemd-localed-read-only.conf
        - require:
            - service: dbus


default-locale-gen:
    locale.present:
        - name: en_US.UTF-8
        - require:
            - file: remove-locale-gen-dbus-restriction


default-locale-set:
    locale.system:
        - name: en_US.UTF-8
        - require:
            - locale: default-locale-gen
            - file: remove-locale-gen-dbus-restriction
        - order: 2


# Provide the salt-master with an event so it knows that the highstate is done.
# We use this, for example, to sync saltmine data.
trigger-minion-sync:
    event.send:
        - name: maurusnet/highstate/complete
        - order: last


# always allow ssh in
openssh-in22-recv-ipv4:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - source: '0/0'
        - proto: tcp
        - dport: 22
        - match: state
        - connstate: new
        - save: True
        - require:
            - sls: basics.nftables.setup
        - order: 4


# NETWORK SERVICES ON THE INTERNET ===========================================
# ssh out, dns out, http out, ntp out, https out
# pgp keyserver hkp out
# Note: Consul is installed on all machines so it's covered by consul.install
{%- set tcp = ['22', '53', '80', '123', '443', '11371'] %}

# dns out, dhcp out, ntp out
{%- set udp = ['53', '67', '123'] %}

{% for port in tcp %}
# allow us to contact others on ports
basics-tcp-out{{port}}-send-ipv4:
    nftables.append:
        - table: filter
        - chain: output
        - family: ip4
        - jump: accept
        - destination: '0/0'
        - dport: {{port}}
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - order: 4


basics-tcp-out{{port}}-send-ipv6:
    nftables.append:
        - table: filter
        - chain: output
        - family: ip6
        - jump: accept
        - destination: '::/0'
        - dport: {{port}}
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - order: 4
{% endfor %}


{% for port in udp %}
# allow others to answer. For UDP we make this stateless here to guarantee it works.
basics-udp-out{{port}}-recv-ipv4:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip4
        - jump: accept
        - proto: udp
        - sport: {{port}}
        - save: True
        - order: 4


basics-udp-out{{port}}-recv-ipv6:
    nftables.append:
        - table: filter
        - chain: input
        - family: ip6
        - jump: accept
        - proto: udp
        - sport: {{port}}
        - save: True
        - order: 4


# allow us to talk to others. For UDP we make this stateless here to guarantee it works.
basics-udp-out{{port}}-send-ipv4:
    nftables.append:
        - table: filter
        - chain: output
        - family: ip4
        - jump: accept
        - proto: udp
        - dport: {{port}}
        - save: True
        - order: 4


basics-udp-out{{port}}-send-ipv6:
    nftables.append:
        - table: filter
        - chain: output
        - family: ip6
        - jump: accept
        - proto: udp
        - dport: {{port}}
        - save: True
        - order: 4
{% endfor %}


# OPEN THE INTERNAL NETWORK FOR OUTGOING CONNECTIONS =========================
basics-internal-network-tcp-ipv4:
    nftables.append:
        - table: filter
        - chain: output
        - family: ip4
        - jump: accept
        - of: {{pillar['ifassign']['internal']}}
        - match: state
        - connstate: new
        - proto: tcp
        - save: True
        - order: 4
        - require:
            - sls: basics.nftables.setup


basics-internal-network-udp-ipv4:
    nftables.append:
        - table: filter
        - chain: output
        - family: ip4
        - jump: accept
        - of: {{pillar['ifassign']['internal']}}
        - proto: udp
        - save: True
        - order: 4
        - require:
            - sls: basics.nftables.setup


# vim: syntax=yaml
