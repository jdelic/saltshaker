
jenkins:
    pkgrepo.managed:
        - humanname: Jenkins CI
        - name: {{pillar["repos"]["jenkins"]}}
        - file: /etc/apt/sources.list.d/jenkins.list
        - key_url: http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key
        - require_in:
            - pkg: jenkins
        - require:
            - pkg: python-apt-packages

    pkg.installed:
        - name: jenkins
        - require:
            - pkgrepo: jenkins
            - pkg: openjdk-8-jre-headless

    service:
        - name: jenkins
        - running
        - require:
            - pkg: jenkins

# vim: syntax=yaml

