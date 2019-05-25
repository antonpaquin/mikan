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

{% if pillar['jupyter_node'] == grains['id'] %}
/home/mikan/jupyter-env:
    virtualenv.managed:
        - venv_bin: /home/mikan/.pyenv/versions/{{ python_version }}/bin/virtualenv
        - python: /home/mikan/.pyenv/versions/{{ python_version }}/bin/python
        - requirements: salt://python/jupyter-requirements.txt
        - unless: 
            - test -d /home/mikan/jupyter-env

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
            - virtualenv: /home/mikan/jupyter-env
        - watch:
            - file: /home/mikan/jupyter_notebook_config.py
{% endif %}
