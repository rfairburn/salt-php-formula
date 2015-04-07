{% from "php/map.jinja" import php with context %}
{% set use_apache24 = salt['pillar.get']('php:use_apache24_formula', False) %}

{% set fpm = salt['pillar.get']('php:fpm', False) %}
include:
  - php.package
{% if fpm %}
  - php.fpm
{% endif %}
{% if use_apache24 %}
  - apache24
{% endif %}

{% for conf_d_file, settings in salt['pillar.get']('php:conf_d', {}).items() %}
{% set conf_d_full_path = '{0}/{1}.conf'.format(php.conf_dir, conf_d_file) %}
{{ conf_d_full_path }}:
  file.managed:
    - user: root
    - group: root
    - mode: '0644'
    - template: jinja
    - source: salt://php/files/conf.tmpl
    - context:
        config: {{ settings.get('config', {})|json }}
    - require:
        - pkg: php
  {% if use_apache24 %}
        - pkg: apache24
  {% endif %}
  {% if fpm %}
        - pkg: php-fpm
    - listen_in:
        - module: php-fpm-restart
  {% elif use_apache24 %}
  # Only worry about the apache24 service if
  # if not php-fpm.  Otherwise we can operate independently
        - module: apache24-restart
  {% endif %}
{% endfor %}
