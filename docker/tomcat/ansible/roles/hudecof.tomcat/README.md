# TOMCAT

## Overview
It is very hard to write a generic role for the ansible configuration.

This role suppose to use includes so you can write your own piece of the configuration files
and include them to the main config.

To keep he server.xml configration file generation simple /KISS/ I use power of the jinja2 tempalte engine and includes.

## Requirements
This role requires Ansible 1.4 or higher and platform requirements are listed in the metadata file.

## Role Variables

### Distribution specific
These variables are in `var/Debian.yml` and `vars/RedHat.yml`.
They are included based on the distribution of the target system.

### Global
These variables are in `defaults/main.yml`.

`tomcat_user` and `tomcat_group` are system user and system group to be created and apache tomcat will run under.

`tomcat_download_prefix` is the URL which is prefixed to all downloads. I downloaded all packages on local server. It could be _http://download.acme.org/java_.

`tomcat_install_dir` si the directory name where to install apache tomcat.

`tomcat_download_dir` is the directory where to download the tar.gz file.

`tomcat_list` is he ist of available tomcat version. This is allows youto install different versions of the tomcat to different servers.  This variable could be global to all hosts.

    tomcat_list:
      v7.0.52:
        filename: 'apache-tomcat/7.0.52/apache-tomcat-7.0.52.tar.gz'
        dirname: 'apache-tomcat-7.0.52'
      v7.0.55:
        filename: 'apache-tomcat/7.0.55/apache-tomcat-7.0.55.tar.gz'
        dirname: 'apache-tomcat-7.0.55'
      v8.0.9:
       filename: 'apache-tomcat/8.0.9/apache-tomcat-8.0.9.tar.gz'
       dirname: 'apache-tomcat-8.0.9'

where 

- **filename** is the location of the tar.gz file. The `tomcat_download_prefix` will be prepended.
- **dirname** is the created directory after unpacking

`tomcat_version` is the key from the `tomcat_list.`

I put **work**, **webapps** and **access logs** into `tomcat_apps_dir`, which is outside of the instalation directory of the tomcat.

in `tomcat_extra_libs` put some extra librarries, which should be shared with all applications of youneed them to configure tomcat. for example _JMX_

    tomcat_extra_libs:
      - state: enabled
        src: apache-tomcat/7.0.55/catalina-jmx-remote.jar
        dest: lib/catalina-jmx-remote.jar

where

- **state** is enabled and disabled. The file downloaded form URL (prefixed by `tomcat_download_dir`) of removed from the _dest_
- **src**, **dest** are self explanatory

`tomcat_extra_conf` is the same as `tomcat_extra_libs`, but the files are search in role template directory

`tomcat_catalina_opts` is an array of CATALINA_OPTS to be added into **setenv.sh**

`tomcat_java_opts` is an array of JAVA_OPTS to be added into **setenv.sh**

if `tomcat_java_home` is set, it will be used as JAVA_HOME

`tomcat_config_template` determined the server.xml template to be used.

`tomcat_dir_prefix` id defaults the **.** which meas all templates files will be searched in role firecotry. I'm using this variable to separate the template files form the role while I'm using this role on more projects and different teams. Ypu can put here absolute or relative path.

### Server.xml
I added an example _server.xml_ fie as **conf/server_default.j2**. As I said, it's very hard to write universal server.xml, so I decided to use includes and the `tomcat_config_template`  variable (defaults: default).

    <?xml version='1.0' encoding='utf-8'?>
    <!-- {{ ansible_managed }} -->
    {% include 'server/server_default_start.j2' %}
    {% include 'server/listener_default.j2' %}
    {% include 'server/service_default_start.j2' %}
    {% include 'server/connector_default_http.j2' %}
    {% include 'server/connector_default_ajp.j2' %}
    {% include 'server/engine_default_start.j2' %}
    {% include 'server/host_default_start.j2' %}
    {% include 'server/valve_log_default.j2' %}
    {% include 'server/host_end.j2' %}
    {% include 'server/engine_stop.j2' %}
    {% include 'server/service_end.j2' %}
    {% include 'server/server_end.j2' %}