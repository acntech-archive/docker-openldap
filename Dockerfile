FROM ubuntu:16.04
MAINTAINER Thomas Johansen "thomas.johansen@accenture.com"


ARG LDAP_DOMAIN=acntech.no
ARG LDAP_ORG=AcnTech
ARG LDAP_HOSTNAME=ldap.acntech.internal
ARG LDAP_PASSWORD=welcome1


ENV SHELL /bin/bash
ENV DEBIAN_FRONTEND noninteractive


RUN echo "shell /bin/bash" > ~/.screenrc

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d


# Update Linux and install common packages
RUN apt-get -y update
RUN apt-get -y -o Dpkg::Options::="--force-confdef" upgrade
RUN apt-get -y dist-upgrade
RUN apt-get -y install apt-utils sudo net-tools rsyslog vim ca-certificates


# Install OpenLDAP
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


# Copy files
COPY files /tmp/files


# Change LDAP root password and logging
RUN chmod +x /tmp/files/modify_slapd_config.sh
RUN /tmp/files/modify_slapd_config.sh ${LDAP_PASSWORD}
RUN echo "local4.*			/var/log/sldapd.log" > /etc/rsyslog.d/slapd.conf


# Install phpLDAPadmin
RUN apt-get -y install phpldapadmin


# Script to SED replace entries in phpLDAPadmin config file
RUN chmod +x /tmp/files/modify_phpldapadmin_config.sh
RUN /tmp/files/modify_phpldapadmin_config.sh ${LDAP_DOMAIN} ${LDAP_ORG} ${LDAP_HOSTNAME}


# Set FQDN for Apache Webserver
RUN echo "ServerName ${LDAP_HOSTNAME}" > /etc/apache2/conf-available/fqdn.conf
RUN sudo a2enconf fqdn


# Cleanup Apt
RUN apt-get autoremove
RUN apt-get autoclean
RUN apt-get clean


EXPOSE 389 636 80


COPY files/entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]