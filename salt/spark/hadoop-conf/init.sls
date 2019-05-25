/home/hadoop/hadoop/etc/hadoop/core-site.xml:
    file.managed:
        - source: salt://spark/hadoop-conf/core-site.xml
        - user: hadoop
        - group: hadoop
        - mode: 644
        - template: jinja
        - context:
            spark_master: {{ pillar['spark_master'] }}
        - require:
            - archive: /home/hadoop/hadoop

/home/hadoop/hadoop/etc/hadoop/hdfs-site.xml:
    file.managed:
        - source: salt://spark/hadoop-conf/hdfs-site.xml
        - user: hadoop
        - group: hadoop
        - mode: 644
        - require:
            - archive: /home/hadoop/hadoop

/home/hadoop/hadoop/etc/hadoop/mapred-site.xml:
    file.managed:
        - source: salt://spark/hadoop-conf/mapred-site.xml
        - user: hadoop
        - group: hadoop
        - mode: 644
        - require:
            - archive: /home/hadoop/hadoop

/home/hadoop/hadoop/etc/hadoop/yarn-site.xml:
    file.managed:
        - source: salt://spark/hadoop-conf/yarn-site.xml
        - user: hadoop
        - group: hadoop
        - mode: 644
        - template: jinja
        - context:
            spark_master: {{ pillar['spark_master'] }}
        - require:
            - archive: /home/hadoop/hadoop

/home/hadoop/hadoop/etc/hadoop/hadoop-env.sh:
    file.managed:
        - source: salt://spark/hadoop-conf/hadoop-env.sh
        - user: hadoop
        - group: hadoop
        - mode: 644
        - template: jinja
        - context:
            spark_master: {{ pillar['spark_master'] }}
        - require:
            - archive: /home/hadoop/hadoop

/home/hadoop/hadoop/etc/hadoop/yarn-env.sh:
    file.managed:
        - source: salt://spark/hadoop-conf/yarn-env.sh
        - user: hadoop
        - group: hadoop
        - mode: 644
        - require:
            - archive: /home/hadoop/hadoop


/home/hadoop/hadoop/etc/hadoop/workers:
    file.managed:
        - user: hadoop
        - group: hadoop
        - mode: 644
        - contents:
{% for server in salt['mine.get']('*', 'grains.item').values() %}
{% if server['id'] != pillar['spark_master'] %}
            - {{ server['id'] }}
{% endif %}
{% endfor %}

hadoop-configured:
    test.nop:
        - require:
            - file: /home/hadoop/hadoop/etc/hadoop/core-site.xml
            - file: /home/hadoop/hadoop/etc/hadoop/hdfs-site.xml
            - file: /home/hadoop/hadoop/etc/hadoop/mapred-site.xml
            - file: /home/hadoop/hadoop/etc/hadoop/yarn-site.xml
            - file: /home/hadoop/hadoop/etc/hadoop/hadoop-env.sh
            - file: /home/hadoop/hadoop/etc/hadoop/yarn-env.sh
            - file: /home/hadoop/hadoop/etc/hadoop/workers
