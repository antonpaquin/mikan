{% if pillar['reverse_proxy'] == grains['id'] %}
nginx:
    pkg.installed: []
    service.running:
        - enable: True
        - watch:
            - file: /etc/nginx/nginx.conf

/etc/nginx/nginx.conf:
    file.managed:
        - source: salt://nginx/nginx.conf
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - context:
            ganglia_head: {{ pillar['ganglia_head'] }}
            jupyter_node: {{ pillar['jupyter_node'] }}

/srv/www/:
    file.recurse:
        - source: salt://nginx/website
        - clean: True
        - user: root
        - group: root
        - dir_mode: 755
        - file_mode: 644
{% endif %}
