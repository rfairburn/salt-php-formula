{% from "php/map.jinja" import php with context %}

include:
  - php.package
  - php.fpm

{% for fpm_d_file, settings in salt['pillar.get']('php:fpm_conf_d', {}).items() %}
{% set fpm_conf_d_full_path = '{0}/{1}.conf'.format(php.fpm_d_dir, fpm_d_file) %}
{{ fpm_conf_d_full_path }}:
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
        - pkg: php-fpm
    - listen_in:
        - module: php-fpm-restart
{% endfor %}
