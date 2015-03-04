{% set db = pillar['junction']['db'] %}
junction_code:
  git.latest:
    - name: https://github.com/pythonindia/junction.git
    - rev: {{ pillar['junction']['revs']['junction']}}
    - target: /opt/junction
    - user: app
    - require:
      - file: /opt/junction

/opt/envs/junction:
  virtualenv.managed:
    - system_site_packages: False
    - requirements: /opt/junction/requirements.txt
    - require:
      - git: junction_code
      - pkg: virtualenv
      - file: /opt/envs
    - user: app

/opt/envs/junction/bin/python manage.py migrate:
  cmd.run:
    - name:
    - cwd: /opt/junction
    - require:
      - virtualenv: /opt/envs/junction
      - file: /opt/junction/settings/prod.py

/opt/junction/settings/prod.py:
  file.managed:
    - user: app
    - source: salt://junction/files/settings.py.j2
    - template: jinja
    - defaults:
      db: {{ db }}
      admins: {{ pillar['junction']['admins']}}

/opt/envs/junction/bin/python manage.py collectstatic --noinput:
  cmd.run:
    - cwd: /opt/junction
    - require:
      - virtualenv: /opt/envs/junction
      - file: /opt/junction/settings/prod.py