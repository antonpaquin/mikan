glusterfs-server:
    pkg.installed: []

/srv/brick:
    file.directory: []

{% if pillar['gluster_init'] == grains['id'] %}
gluster-peered:
    glusterfs.peered:
        - names:
{% for server in salt['mine.get']('*', 'grains.item').values() %}
            - {{ server['id'] }}
{% endfor %}

gluster-volume:
    glusterfs.volume_present:
        - name: mikan
        - bricks:
{% for server in salt['mine.get']('*', 'grains.item').values() %}
            - {{ server['id'] }}:/srv/brick
{% endfor %}
        - start: True
        - force: True
        - require:
            - glusterfs: gluster-peered
{% endif %}

/mikan:
    mount.mounted:
        - device: {{ grains['id'] }}:/mikan
        - fstype: glusterfs
        - mkmnt: True
    file.directory:
        - user: mikan
        - group: mikan
        - dir_mode: 755
