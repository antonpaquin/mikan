/home/mikan/.ssh/mikan.key:
    file.managed:
        - source: salt://ssh/mikan.key
        - user: mikan
        - group: mikan
        - mode: 400
        - makedirs: True

/home/mikan/.ssh/mikan.pub:
    file.managed:
        - source: salt://ssh/mikan.pub
        - user: mikan
        - group: mikan
        - mode: 644
        - makedirs: True

/home/mikan/.ssh/config:
    file.managed:
        - user: mikan
        - group: mikan
        - mode: 644
        - makedirs: True
        - contents:
            - Include hosts.d/*

/home/mikan/.ssh/hosts.d:
    file.directory:
        - user: mikan
        - group: mikan
        - dir_mode: 755

# This depends on data set in mikan/etc.sls, which fills in /etc/hosts
{% for server in salt['mine.get']('*', 'grains.item').values() %}
/home/mikan/.ssh/hosts.d/{{ server['id'] }}:
    file.managed:
        - source: salt://ssh/mikan-ssh.j2
        - user: mikan
        - group: mikan
        - mode: 644
        - template: jinja
        - context:
            hostname: {{ server['id'] }}
{% endfor %}

# ???
/home/mikan/.ssh/hosts.d/localhost:
    file.managed:
        - source: salt://ssh/mikan-ssh.j2
        - user: mikan
        - group: mikan
        - mode: 644
        - template: jinja
        - context:
            hostname: localhost
