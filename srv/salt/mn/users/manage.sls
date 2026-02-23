{%- set users = pillar.get('users', {}) %}
{%- set sshkeys = None %}

{%- for username, user in users.items() %}
    {%- set base_groups = user.get('groups', []) %}
    {%- if user.get('create_default_group', True) and username not in base_groups %}
        {%- set groups = [username] + base_groups %}
    {%- else %}
        {%- set groups = base_groups %}
    {%- endif %}
    {%- set optional_groups = user.get('optional_groups', []) %}
    {%- set home_dir = user.get('home', '/home/' ~ username) %}
    {%- set enable_byobu = user.get('enable_byobu', True) %}
    {%- set set_bashrc = user.get('set_bashrc', True) %}
    {%- set ssh_key_ids = user.get('ssh_keys', []) %}

    {%- for grp in groups %}
group-{{username}}-{{grp}}:
    group.present:
        - name: {{grp}}
    {%- endfor %}

user-{{username}}:
    user.present:
        - name: {{username}}
        - home: {{home_dir}}
        - usergroup: False
        - shell: /bin/bash
    {%- if groups %}
        - groups:
        {%- for grp in groups %}
            - {{grp}}
        {%- endfor %}
    {%- endif %}
    {%- if optional_groups %}
        - optional_groups:
        {%- for grp in optional_groups %}
            - {{grp}}
        {%- endfor %}
    {%- endif %}
    {%- if user.get('password') %}
        - password: {{user.get('password')}}
    {%- endif %}
    {%- if groups %}
        - require:
        {%- for grp in groups %}
            - group: group-{{username}}-{{grp}}
        {%- endfor %}
    {%- endif %}

    {%- if ssh_key_ids %}
sshkeys-{{username}}:
    ssh_auth.manage:
        - user: {{username}}
        - ssh_keys:
        {%- for key_id in ssh_key_ids %}
            - {{key_id | json}}
        {%- endfor %}
        - require:
            - user: user-{{username}}
    {%- endif %}

    {%- if enable_byobu %}
byobu-profile-{{username}}:
    file.append:
        - name: {{home_dir}}/.profile
        - text: |
            if [ "x$MN_TMUX" != "x1" ]; then _byobu_sourced=1 . /usr/bin/byobu-launch 2>/dev/null || true; export MN_TMUX=1; fi
        - unless: grep -q byobu {{home_dir}}/.profile
        - require:
            - pkg: byobu

byobu-dir-{{username}}:
    file.directory:
        - name: {{home_dir}}/.byobu
        - user: {{username}}
        - group: {{username}}
        - makedirs: True
        - mode: '0755'
        - require:
            - user: user-{{username}}

byobu-tmux-config-{{username}}:
    file.managed:
        - name: {{home_dir}}/.byobu/.tmux.conf
        - source: salt://mn/users/tmux-user.conf
        - user: {{username}}
        - group: {{username}}
        - mode: '0644'
        - require:
            - file: byobu-profile-{{username}}
            - file: byobu-dir-{{username}}

byobu-status-config-{{username}}:
    file.managed:
        - name: {{home_dir}}/.byobu/status
        - source: salt://mn/users/status
        - user: {{username}}
        - group: {{username}}
        - mode: '0644'
        - require:
            - file: byobu-profile-{{username}}
            - file: byobu-dir-{{username}}
    {%- endif %}

    {%- if set_bashrc %}
bashrc-{{username}}:
    file.managed:
        - name: {{home_dir}}/.bashrc
        - source: salt://mn/users/bashrc
        - user: {{username}}
        - group: {{username}}
        - mode: '0640'
        - require:
            - user: user-{{username}}
    {%- endif %}

{%- endfor %}

# vim: syntax=yaml
