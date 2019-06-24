{% set python_version = '3.7.3' %}

pyenv-deps:
  pkg.installed:
    - pkgs:
      - make
      - build-essential
      - libssl-dev
      - zlib1g-dev
      - libbz2-dev
      - libreadline-dev
      - libsqlite3-dev
      - libffi-dev
      - wget
      - curl
      - llvm
      - libjpeg-dev

pyenv:
    custom_pyenv.install_pyenv:
        - prefix: /home/mikan

python-{{ python_version }}:
    custom_pyenv.installed:
        - pyenv: /home/mikan/.pyenv
        - require: 
            - custom_pyenv: pyenv

virtualenv:
    custom_pyenv.ensure_venv:
        - pip_bin: /home/mikan/.pyenv/versions/{{ python_version }}/bin/pip
        - require:
            - custom_pyenv: python-{{ python_version }}

/home/mikan/dask:
    file.directory:
        - user: mikan
        - group: mikan
        - dir_mode: 755
        - recurse:
            - user
            - group

/home/mikan/.config/dask/distributed.yaml:
    file.managed:
        - source: salt://python/dask-config.yaml
        - user: mikan
        - group: mikan
        - mode: 644
        - makedirs: True

/home/mikan/mikan-env:
    virtualenv.managed:
        - venv_bin: /home/mikan/.pyenv/versions/{{ python_version }}/bin/virtualenv
        - python: /home/mikan/.pyenv/versions/{{ python_version }}/bin/python
        - requirements: salt://python/requirements.txt
        - unless: 
            - test -d /home/mikan/mikan-env

{% if pillar['jupyter_node'] == grains['id'] %}
/home/mikan/jupyter_notebook_config.py:
    file.managed:
        - source: salt://python/jupyter_notebook_config.py
        - user: mikan
        - group: mikan
        - mode: 644

/lib/systemd/system/jupyter-lab.service:
    file.managed:
        - source: salt://python/jupyter-lab.service
        - user: root
        - group: root
        - mode: 644

jupyter-lab:
    service.running:
        - require:
            - file: /lib/systemd/system/jupyter-lab.service
            - virtualenv: /home/mikan/mikan-env
        - watch:
            - file: /home/mikan/jupyter_notebook_config.py

/lib/systemd/system/dask-scheduler.service:
    file.managed:
        - source: salt://python/dask-scheduler.service
        - user: root
        - group: root
        - mode: 644

dask-scheduler:
    service.running:
        - require:
            - file: /lib/systemd/system/dask-scheduler.service
            - virtualenv: /home/mikan/mikan-env
{% endif %}

/lib/systemd/system/dask-worker.service:
    file.managed:
        - source: salt://python/dask-worker.service
        - user: root
        - group: root
        - mode: 644
        - template: jinja
        - context:
            dask_scheduler: {{ pillar['jupyter_node'] }}
            worker_name: {{ grains['id'] }}

dask-worker:
    service.running:
        - require:
            - file: /lib/systemd/system/dask-worker.service
            - virtualenv: /home/mikan/mikan-env
