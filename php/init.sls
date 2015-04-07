{% load_yaml as includes %}
- modules
- config
- conf_d
- fpm
- fpm_conf
- fpm_conf_d
{% endload %}

include:
  - php.package
{% for include in includes %}
  {% if include in salt['pillar.get']('php', {}) %}
  - php.{{ include }}
  {% endif %}
{% endfor %}
