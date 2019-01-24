# -*- coding: utf-8 -*-
# vim: ft=sls

{%- from "solr4/map.jinja" import solr4 with context %}


{%- if "file" in solr4.archive %}
# User has provided a local archive for the installation
{%-   set archive_file = solr4.archive.file %}
{%- else %}
{%-   set archive_file = solr4.install_dir ~ '/solr-' ~ solr4.version ~ '.tgz' %}

{%-   if "source" in solr4.archive %}
# User has provided a custom source for the archive
{%-     set archive_src = solr4.archive.source %}
{%-     if "source_hash" in solr4.archive %}
{%-       set source_hash = solr4.archive.source_hash %}
{%-     endif %}
{%-   else %}
{%-     set archive_src = solr4.archive.host ~ solr4.archive.path ~ '/' ~ solr4.version ~ '/solr-' ~ solr4.version ~ '.tgz' %}
{%-     set source_hash = archive_src ~ '.md5' %}
{%-   endif %}

#
# The archive must be saved locally for extraction and installation
#
solr4-download:
  file.managed:
    - name: {{ archive_file }}
    - source: {{ archive_src }}
{%-   if "source_hash" is defined %}
    - source_hash: {{ source_hash }}
{%-   else %}
    - skip_verify: True
{%- endif %}
    - require_in:
      - cmd: solr4-extract-installer
{%- endif %}


#
# Extract the installation script from the archive
#
solr4-extract-installer:
  cmd.run:
    - cwd: {{ solr4.install_dir }}
    - name: tar xzf {{ archive_file }} solr-{{ solr4.version }}/bin/install_solr_service.sh --strip-components=2
    - onchanges:
      - file: solr4-download


#
# Install the service using the extracted files and the saved archive
#
solr4-install:
  cmd.run:
    - cwd: {{ solr4.install_dir }}
    - name: {{ solr4.install_dir }}/install_solr_service.sh {{ archive_file }} -f -u {{ solr4.user }} -d {{ solr4.data_dir }}
    - onchanges:
      - cmd: solr4-extract-installer

#
# Make sure the version symlink has been updated
#
solr4-symlink:
  file.symlink:
    - name: {{ solr4.install_dir }}/solr
    - target: {{ solr4.install_dir }}/solr-{{ solr4.version }}
    - watch_in:
      - service: solr4
