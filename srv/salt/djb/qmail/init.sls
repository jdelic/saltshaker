
{% from 'djb/qmail/users.sls' import qmail_users %}

# a recipe to install the maurus.net build of Jon Simpson's
# qmail combined patch

include:
    - djb
    - djb.qmail.users
    - djb.qmail.services
    - djb.qmail.jgreylist


var-qmail-directory:
    file.exists:
        - name: /var/qmail
        - require:
            - cmd: qmail-install


qmail-ssl-cert:
    file.managed:
        - name: {{pillar['smtp']['sslcert']}}
        - user: qmaild
        - group: root
        - mode: 400
        - contents_pillar: ssl:maincert:combined-key
        - require:
            - file: ssl-key-location


# this state has order=1 to prevent apt from auto-installing Exim
qmail-equivs:
    pkg.installed:
        - sources:
            - qmail-jm: salt://djb/qmail/equivs/qmail-jm_1.03_all.deb
        - order: 1
# workaround for #8015
#/tmp/qmail-jm_1.03_all.deb:
#    file.managed:
#        - source: salt://djb/qmail/equivs/qmail-jm_1.03_all.deb
#
#qmail-equivs:
#    cmd.run:
#        - name: /usr/bin/dpkg -i --force-confold /tmp/qmail-jm_1.03_all.deb
#        - require:
#            - file: /tmp/qmail-jm_1.03_all.deb
#        - order: 1



sendmail-symlinks:
    file.symlink:
        - target: /var/qmail/bin/sendmail
        - names:
            - /usr/sbin/sendmail
            - /usr/lib/sendmail
        - require:
            - file: var-qmail-directory


qmail-mailqueue-remove-default:
    cmd.run:
        - name: rm -rf /var/qmail/queue
        - unless: test -h /var/qmail/queue
        - onlyif: test -d /var/qmail/queue
        - require:
            - file: var-qmail-directory
            {% for user in qmail_users %}
            - user: {{user}}
            {% endfor %}


qmail-mailqueue-symlink:
    file.symlink:
        - target: /mailqueue
        - name: /var/qmail/queue
        - require:
            - file: var-qmail-directory
            - cmd: qmail-mailqueue-remove-default
            {% for user in qmail_users %}
            - user: {{user}}
            {% endfor %}
    # djb.qmail.mounts.* set a require_in for this state


qmail-mailqueue-create:
    cmd.script:
        - name: create-mailqueue.sh /mailqueue
        - source: salt://djb/qmail/create-mailqueue.sh
        - cwd: /mailqueue
        - user: root
        - group: root
        - unless: test -e /mailqueue/mess
        - require:
            {% for user in qmail_users %}
            - user: {{user}}
            {% endfor %}
    # djb.qmail.mounts.* set a require_in for this state


qmail-source-archive:
    file.managed:
        - name: /usr/local/src/djb/qmail-1.03.tar.gz
        - source: {{pillar["urls"]["qmail"]}}
        - source_hash: {{pillar["hashes"]["qmail"]}}
        - require:
             - file: djb-source-build-directory


qmail-jms1-patch:
    file.managed:
        - name: /usr/local/src/djb/qmail-1.03-jms1-7.10.patch
        - source: salt://djb/qmail/qmail-1.03-jms1-7.10.patch


qmail-install:
    cmd.script:
        - args: {{grains['fqdn']}}
        - source: salt://djb/qmail/install.sh
        - cwd: /usr/local/src/djb
        - user: root
        - group: root
        - require:
            - file: qmail-jms1-patch
            - file: qmail-source-archive
            {% for user in qmail_users %}
            - user: {{user}}
            {% endfor %}
            - pkg: ucspi-tcp
            - pkg: daemontools
            - sls: compilers
        - unless: test -e /var/qmail/bin/qmail-inject

# -* vim: syntax=yaml

