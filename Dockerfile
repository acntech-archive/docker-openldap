FROM ubuntu:16.04
MAINTAINER Thomas Johansen "thomas.johansen@accenture.com"


RUN apt-get -y update

RUN apt-get -y install slapd ldap-utils phpldapadmin


CMD ["/bin/bash"]