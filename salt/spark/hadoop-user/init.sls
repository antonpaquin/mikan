hadoop-user:
    user.present:
        - name: hadoop
        - home: /home/hadoop
        - shell: /bin/bash
        - createhome: True

/home/hadoop/.profile:
    file.managed:
        - source: salt://spark/hadoop-user/bash-profile
        - user: hadoop
        - group: hadoop
        - mode: 644

/home/hadoop/.bashrc:
    file.managed:
        - user: hadoop
        - group: hadoop
        - mode: 644
        - contents:
            - 'source /home/hadoop/.profile'

/etc/profile.d/hadoop-home.sh:
    file.managed:
        - source: salt://spark/hadoop-user/hadoop-home.sh
        - user: root
        - group: root
        - mode: 644

/home/hadoop/.ssh/hadoop.key:
    file.managed:
        - source: salt://spark/hadoop-user/hadoop.key
        - user: hadoop
        - group: hadoop
        - mode: 400
        - makedirs: True

/home/hadoop/.ssh/hadoop.pub:
    file.managed:
        - source: salt://spark/hadoop-user/hadoop.pub
        - user: hadoop
        - group: hadoop
        - mode: 644
        - makedirs: True

/home/hadoop/.ssh/authorized_keys:
    file.managed:
        - source: salt://spark/hadoop-user/hadoop.pub
        - user: hadoop
        - group: hadoop
        - mode: 644
        - makedirs: True

/home/hadoop/.ssh/config:
    file.managed:
        - user: hadoop
        - group: hadoop
        - mode: 644
        - makedirs: True
        - contents:
            - Include hosts.d/*

/home/hadoop/.ssh/hosts.d:
    file.directory:
        - user: hadoop
        - group: hadoop
        - dir_mode: 755

{% for server in salt['mine.get']('*', 'grains.item').values() %}
/home/hadoop/.ssh/hosts.d/{{ server['id'] }}:
    file.managed:
        - source: salt://spark/hadoop-user/hadoop-ssh.j2
        - user: hadoop
        - group: hadoop
        - mode: 644
        - template: jinja
        - context:
            hostname: {{ server['id'] }}
{% endfor %}

/home/hadoop/.ssh/hosts.d/localhost:
    file.managed:
        - source: salt://spark/hadoop-user/hadoop-ssh.j2
        - user: hadoop
        - group: hadoop
        - mode: 644
        - template: jinja
        - context:
            hostname: localhost
