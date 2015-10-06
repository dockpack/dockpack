#Dockerfile
FROM centos:centos6
MAINTAINER Bas Meijer <datasmid@yahoo.com>

RUN yum update -y
RUN yum install -y epel-release
RUN yum install -y ansible
ADD ansible /tmp/ansible
RUN cd /tmp/ansible && ansible-playbook playbook.yml 

ENV CATALINA_HOME /opt/apache-tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
WORKDIR $CATALINA_HOME
EXPOSE 8080
CMD /opt/apache-tomcat/bin/catalina.sh run
#End
