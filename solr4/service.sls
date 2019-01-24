# -*- coding: utf-8 -*-
# vim: ft=sls

{% from "solr4/map.jinja" import solr4 with context %}

solr4:
  service.running:
    - name: {{ solr4.service.name }}
    - enable: True
