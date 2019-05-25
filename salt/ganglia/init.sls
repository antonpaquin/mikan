ganglia-monitor:
    pkg.installed: []
    service.running:
        - enable: True
        - watch:
            - file: /etc/ganglia/gmond.conf

/etc/ganglia/gmond.conf:
    file.managed:
        - source: salt://ganglia/gmond.conf
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - context:
            recv: {{ pillar['ganglia_head'] == grains['id'] }}

{% if pillar['ganglia_head'] == grains['id'] %}
gmetad:
    pkg.installed: []
    service.running:
        - enable: True
        - watch:
            - file: /etc/ganglia/gmetad.conf

ganglia-webfrontend:
    pkg.installed: []

/etc/ganglia/gmetad.conf:
    file.managed:
        - source: salt://ganglia/gmetad.conf
        - user: root
        - group: root
        - mode: 644

/etc/apache2/sites-enabled/ganglia-web.conf:
    file.managed:
        - source: salt://ganglia/ganglia-web.conf
        - user: root
        - group: root
        - mode: 644

ganglia-apache2:
    service.running:
        - name: apache2
        - enable: True
        - watch:
            - file: /etc/apache2/sites-enabled/ganglia-web.conf
{% endif %}
