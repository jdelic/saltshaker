
jenkins:
    pkgrepo.managed:
        - humanname: Jenkins CI
        - name: {{pillar["repos"]["jenkins"]}}
        - file: /etc/apt/sources.list.d/jenkins.list
        - key_url: salt://dev/jenkins_E12A9B7D32F2D50582E6.pgp.key
        - require_in:
            - pkg: jenkins
        - require:
            - pkg: python-apt-packages

    pkg.installed:
        - name: jenkins
        - require:
            - pkgrepo: jenkins
            - pkg: openjdk-8-jre-headless

    service.running:
        - name: jenkins
        - enable: True
        - require:
            - pkg: jenkins

# vim: syntax=yaml

