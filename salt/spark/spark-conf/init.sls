/home/hadoop/spark/conf/spark-defaults.conf:
    file.managed:
        - source: salt://spark/spark-conf/spark-defaults.conf
        - user: hadoop
        - group: hadoop
        - mode: 644
        - require:
            - archive: /home/hadoop/spark

spark-configured:
    test.nop:
        - require:
            - file: /home/hadoop/spark/conf/spark-defaults.conf
