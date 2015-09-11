
samba:
    pkg:
        - installed
    file.managed:
        - name: /etc/samba/smb.conf
        - source: salt://samba/smb.conf.tpl
        - template: jinja
        - user: root
        - group: root
        - mode: 0644
        - require:
            - pkg: samba


smbd:
    service.running:
        - enable: True
        - watch:
             - file: /etc/samba/smb.conf
        - require:
            - pkg: samba
            - file: /etc/samba/smb.conf
            - file: /mnt/smb


/mnt/smb:
    file.directory:
         - user: vagrant
         - group: vagrant
         - recurse:
             - user
             - group
         - dir_mode: '0755'
         - file_mode: '0644'
         - require:
              - user: vagrant


# portlist from https://wiki.samba.org/index.php/Samba_port_usage
{% for port in ['88', '135', '139', '389', '445', '464', '636', '1024:5000', '3268', '3269', '5353'] %}
# allow others to contact us on ports
samba-tcp-in{{port}}-recv:
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


{% for port in ['88', '137', '138', '389', '445', '464', '5353'] %}
samba-udp-in{{port}}-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - in-interface: {{pillar['ifassign']['internal']}}
        - proto: udp
        - dport: {{port}}
        - save: True
        - require:
            - sls: iptables


samba-udp-in{{port}}-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - out-interface: {{pillar['ifassign']['internal']}}
        - proto: udp
        - sport: {{port}}
        - save: True
        - require:
            - sls: iptables
{% endfor %}


# also allow NMBD broadcasts on the internal network
{% for port in ['137', '138'] %}
samba-udp-in{{port}}-broadcast-recv:
    iptables.append:
        - table: filter
        - chain: INPUT
        - jump: ACCEPT
        - in-interface: {{pillar['ifassign']['internal']}}
        - sport: {{port}}
        - dport: {{port}}
        - proto: udp
        - match: pkttype
        - pkt-type: broadcast
        - save: True
        - require:
            - sls: iptables

samba-udp-out{{port}}-broadcast-send:
    iptables.append:
        - table: filter
        - chain: OUTPUT
        - jump: ACCEPT
        - out-interface: {{pillar['ifassign']['internal']}}
        - sport: {{port}}
        - dport: {{port}}
        - proto: udp
        - match: pkttype
        - pkt-type: broadcast
        - save: True
        - require:
            - sls: iptables
{% endfor %}


# -* vim: syntax=yaml
