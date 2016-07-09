FROM ubuntu:16.04
MAINTAINER Thomas Johansen "thomas.johansen@accenture.com"


ARG LDAP_DOMAIN
ARG LDAP_ORG
ARG LDAP_PASSWORD
ARG LDAP_HOSTNAME


ENV SHELL /bin/bash
ENV DEBIAN_FRONTEND noninteractive


RUN echo "shell /bin/bash" > ~/.screenrc

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

RUN apt-get -y update
RUN apt-get -y install apt-utils
RUN apt-get -y upgrade
RUN apt-get -y dist-upgrade
RUN apt-get -y install sudo net-tools rsyslog vim ca-certificates

RUN echo "slapd slapd/root_password password ${LDAP_PASSWORD}" | debconf-set-selections
RUN echo "slapd slapd/root_password_again password ${LDAP_PASSWORD}" | debconf-set-selections
RUN echo "slapd slapd/internal/adminpw password ${LDAP_PASSWORD}" | debconf-set-selections
RUN echo "slapd slapd/internal/generated_adminpw password ${LDAP_PASSWORD}" | debconf-set-selections
RUN echo "slapd slapd/password2 password ${LDAP_PASSWORD}" | debconf-set-selections
RUN echo "slapd slapd/password1 password ${LDAP_PASSWORD}" | debconf-set-selections
RUN echo "slapd slapd/domain string ${LDAP_DOMAIN}" | debconf-set-selections
RUN echo "slapd shared/organization string ${LDAP_ORG}" | debconf-set-selections
RUN echo "slapd slapd/backend string HDB" | debconf-set-selections
RUN echo "slapd slapd/purge_database boolean true" | debconf-set-selections
RUN echo "slapd slapd/move_old_database boolean true" | debconf-set-selections
RUN echo "slapd slapd/allow_ldap_v2 boolean false" | debconf-set-selections
RUN echo "slapd slapd/no_configuration boolean false" | debconf-set-selections

RUN apt-get -y install slapd ldap-utils
RUN dpkg-reconfigure slapd
RUN apt-get -y install phpldapadmin

RUN dpkg-reconfigure tzdata

RUN apt-get clean

# Script to SED replace entries in phpLDAPadmin config file
ADD files/phpldapadmin.config.php.sh /tmp/
RUN /tmp/phpldapadmin.config.php.sh ${LDAP_DOMAIN} ${LDAP_ORG} ${LDAP_HOSTNAME}


RUN echo "ServerName ${LDAP_HOSTNAME}" > /etc/apache2/conf-available/fqdn.conf
RUN sudo a2enconf fqdn


EXPOSE 389 636 80


CMD ["/bin/bash"]