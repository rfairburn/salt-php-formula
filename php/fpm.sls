{% from "php/map.jinja" import php with context %}
{% set modules = salt['pillar.get']('php:modules', {}) %}
{% set use_apache24 = salt['pillar.get']('php:use_apache24_formula', False) %}

include:
  - php.package
{% if modules %}
  - php.modules
{% endif %}
{% if use_apache24 %}
  - apache24

  {% from "apache24/map.jinja" import apache24 with context %}
{% else %}
  # Force the .get below to use defaults
  {% set apache24 = {} %}
{% endif %}

php-fpm:
  pkg.installed:
    - name: {{ php.fpm_package }}
    - require:
      - pkg: php
{% if modules %}
      # Require the whole sls as we might have modules packages or pecl modules
      - sls: php.modules
{% endif %}
{% if use_apache24 %}
      - pkg: apache24
{% endif %}
  service.running:
    - name: {{ php.fpm_service }}
    - enable: True

php-fpm-reload:
  module.wait:
    - name: service.reload
    - m_name: {{ php.fpm_service }}

php-fpm-restart:
  module.wait:
    - name: service.restart
    - m_name: {{ php.fpm_service }}

{{ php.apache24_module }}:
  file.absent:
    - name: {{ apache24.get('modules_dir', '/etc/httpd/conf.modules.d') }}/{{ php.apache24_module }}
{% if use_apache24 %}
    - require:
      - pkg: apache24
    - listen_in:
      # Restart apache24 with mod_php disabled.
      - module: apache24-restart
{% endif %}

{{ php.apache24_conf }}:
  file.absent:
    - name: {{ apache24.get('conf_d_dir', '/etc/httpd/conf.d') }}/{{ php.apache24_conf }}
{% if use_apache24 %}
    - require:
      - pkg: apache24
    - listen_in:
      # Restart apache24 with php configs disabled.
      - module: apache24-restart
{% endif %}


