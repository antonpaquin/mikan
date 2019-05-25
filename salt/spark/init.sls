include:
    - spark.hadoop-conf
    - spark.hadoop-user
    - spark.spark-conf

openjdk-8-jre:
    pkg.installed: []

/lib/systemd/system/hdfs.service:
    file.managed:
        - source: salt://spark/hdfs.service
        - user: root
        - group: root
        - mode: 644

/lib/systemd/system/yarn.service:
    file.managed:
        - source: salt://spark/yarn.service
        - user: root
        - group: root
        - mode: 644

/home/hadoop/hadoop:
    archive.extracted:
        - source: http://mirror.cogentco.com/pub/apache/hadoop/common/hadoop-3.1.2/hadoop-3.1.2.tar.gz
        - user: hadoop
        - group: hadoop
        - skip_verify: True
        - enforce_toplevel: False
        - options: ' --strip-components=1'
        - unless:
            - test -d /home/hadoop/hadoop

/home/hadoop/data/nameNode:
    file.directory:
        - user: hadoop
        - group: hadoop
        - makedirs: True
        - dir_mode: 755

/home/hadoop/data/dataNode:
    file.directory:
        - user: hadoop
        - group: hadoop
        - makedirs: True
        - dir_mode: 755

{% if pillar['spark_master'] == grains['id'] %}
hdfs-formatted:
    cmd.run:
        - name: 'sudo JAVA_HOME=/usr/lib/jvm/java-8-openjdk-armhf /home/hadoop/hadoop/bin/hdfs namenode -format mikan'
        - creates: /home/hadoop/data/nameNode/current/VERSION
        - require:
            - test: hadoop-configured

hdfs-service:
    service.running:
        - name: hdfs
        - enable: True
        - require:
            - cmd: hdfs-formatted
            - file: /lib/systemd/system/hdfs.service
            - user: hadoop-user

#yarn-service:
#    service.running:
#        - name: yarn
#        - enable: True
#        - require:
#            - file: /lib/systemd/system/yarn.service
#            - service: hdfs-service
{% endif %}


/home/hadoop/spark:
    archive.extracted:
        - source: http://mirrors.sonic.net/apache/spark/spark-2.4.3/spark-2.4.3-bin-hadoop2.7.tgz
        - user: root
        - group: root
        - skip_verify: True
        - enforce_toplevel: False
        - options: ' --strip-components=1'
        - unless:
            - test -d /home/hadoop/spark

