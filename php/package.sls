{% from "php/map.jinja" import php with context %}
{% set use_apache24 = salt['pillar.get']('php:use_apache24_formula', False) %}

{% if use_apache24 %}
include:
  - apache24
{% endif %} 


php:
  pkg.installed:
    - name: {{ php.package }}
{% if use_apache24 %}
    - require:
      - pkg: apache24
    - listen_in:
      - module: apache24-restart
{% endif %}
