/etc/hostname:
    file.managed:
        - contents:
            - {{ grains['id'] }}
        - user: root
        - group: root
        - mode: 644

blueridge_etc_hosts:
    file.append: 
        - name: /etc/hosts
        - text: 192.168.0.103 blueridge

{% for server in salt['mine.get']('*', 'grains.item').values() %}
{% set addrs = salt['mine.get'](server['id'], 'network.ip_addrs')[server['id']] %}
{% if addrs|length > 0 %}
{{ server['id'] }}_etc_hosts:
    file.append:
        - name: /etc/hosts
        - text: {{ addrs[0] }} {{ server['id'] }}
{% endif %}
{% endfor %}
