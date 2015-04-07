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

php_pear:
  pkg.installed:
    - name: {{ php.pear_package }}
    - require:
        - pkg: php

{% set php_modules = salt['pillar.get']('php:modules:package', []) %}
php_modules:
  pkg.installed:
    - pkgs:
{% for php_module in php_modules %}
        - {{ php.package }}-{{ php_module }}
{% endfor %}
    - require:
        - pkg: php
{% if use_apache24 %}
        - pkg: apache24
{% endif %}
{% if fpm %}
    - listen_in:
        - module: php-fpm-restart
{% elif use_apache24 %}
# Only worry about the apache24 service if
# if not php-fpm.  Otherwise we can operate independently
        - module: apache24-restart
{% endif %}

# Note these will likely require a build chain installed to compile them.
# Make sure you have a state that does an appropriate require_in
# to ensure things work as expected!
{% set pecl_modules = salt['pillar.get']('php:modules:pecl', []) %}
{% for pecl_module in pecl_modules %}
php_pecl_{{ pecl_module }}:
  pecl.installed:
    - name: {{ pecl_module }}
    - require:
        - pkg: php
        - pkg: php_pear
  {% if use_apache24 %}
        - pkg: apache24
  {% endif %}
  {% if fpm %}
    - listen_in:
        - module: php-fpm-restart
  {% elif use_apache24 %}
  # Only worry about the apache24 service if
  # if not php-fpm.  Otherwise we can operate independently
        - module: apache24-restart
  {% endif %}
{% endfor %}

