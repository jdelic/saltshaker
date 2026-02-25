# a "poor man's git server", i.e. a user with repos in their home directory and SSH keys for authentication.

user-git:
    user.present:
        - name: git
        - home: /home/git
        - usergroup: True
        - createhome: True
        - shell: /bin/bash


sshkeys-git:
    ssh_auth.manage:
        - user: git
        - ssh_keys:
{%- for key_id in pillar['gitserver']['allowed_ssh_keys'] %}
            - {{key_id | json}}
{%- endfor %}
{%- for git_user in pillar['gitserver']['allowed_users'] %}
    {%- for key_id in pillar['users'].get(git_user, {}).get('ssh_keys', []) %}
            - {{key_id | json}}
    {%- endfor %}
{%- endfor %}
        - require:
            - user: user-git
{%- for git_user in pillar['gitserver']['allowed_users'] %}
    {%- if pillar['users'].get(git_user, False) %}
            - user: user-{{git_user}}
    {%- endif %}
{%- endfor %}


{% if pillar.get('duplicity-backup', {}).get('enabled', False) %}
git-miniserver-backup-symlink:
    file.symlink:
        - name: /etc/duplicity.d/daily/folderlinks/git-miniserver
        - target: /home/git
        - require:
            - user: user-git
{% else %}
git-miniserver-backup-symlink-absent:
    file.absent:
        - name: /etc/duplicity.d/daily/folderlinks/git-miniserver
{% endif %}
