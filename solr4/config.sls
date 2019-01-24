# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "solr4/map.jinja" import solr4 with context %}


{%- for core, settings in solr4.get('cores', {}).items() %}
solr4-core-{{ core }}:
  cmd.run:
    - name: {{ solr4.install_dir }}/solr-{{ solr4.version }}/bin/solr create -c {{ core }}
    - runas: solr
    - creates: {{ solr4.data_dir }}/data/{{ core }}/
    - require:
      - cmd: solr4-install

solr4-core-{{ core }}-schema:
  file.managed:
    - name: {{ solr4.data_dir }}/data/{{ core }}/conf/managed-schema
    - source: {{ settings.schema|default("salt://files/solr4/schema/" ~ core) }}
    - user: {{ solr4.user }}
    - group: {{ solr4.group }}
    - require:
      - cmd: solr4-core-{{ core }}
{%- endfor %}
