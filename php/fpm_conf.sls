{% from "php/map.jinja" import php with context %}

include:
  - php.package
  - php.fpm

{% set fpm_conf = salt['pillar.get']('php:fpm_conf', {}) %}
{% if fpm_conf %}
{{ php.fpm_conf }}:
  file.managed:
    - user: root
    - group: root
    - mode: '0644'
    - template: jinja
    - source: salt://php/files/conf.tmpl
    - context:
        config: {{ fpm_conf|json }}
    - require:
        - pkg: php
        - pkg: php-fpm
    - listen_in:
        - module: php-fpm-restart
{% endif %}
