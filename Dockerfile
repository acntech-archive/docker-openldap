FROM ubuntu:16.04
MAINTAINER Thomas Johansen "thomas.johansen@accenture.com"


ARG LDAP_DOMAIN
ARG LDAP_ORG
ARG LDAP_HOSTNAME
ARG LDAP_PASSWORD


ENV SHELL /bin/bash
ENV DEBIAN_FRONTEND noninteractive


RUN echo "shell /bin/bash" > ~/.screenrc

# Keep upstart from complaining
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -sf /bin/true /sbin/initctl

# Avoid ERROR: invoke-rc.d: policy-rc.d denied execution of start.
RUN echo "#!/bin/sh\nexit 0" > /usr/sbin/policy-rc.d

RUN apt-get -y update
RUN apt-get -y upgrade
RUN apt-get -y dist-upgrade
RUN apt-get -y install apt-utils sudo net-tools rsyslog vim ca-certificates ldap-utils

# Install OpenLDAP
RUN echo "slapd slapd/root_password password ${LDAP_PASSWORD}" | debconf-set-selections
RUN echo "slapd slapd/root_password_again password ${LDAP_PASSWORD}" | debconf-set-selections
RUN echo "slapd slapd/internal/adminpw password ${LDAP_PASSWORD}" | debconf-set-selections
RUN echo "slapd slapd/internal/generated_adminpw password ${LDAP_PASSWORD}" | debconf-set-selections
RUN echo "slapd slapd/password2 password ${LDAP_PASSWORD}" | debconf-set-selections
RUN echo "slapd slapd/password1 password ${LDAP_PASSWORD}" | debconf-set-selections
RUN echo "slapd slapd/domain string acntech.no" | debconf-set-selections
RUN echo "slapd shared/organization string AcnTech" | debconf-set-selections
RUN echo "slapd slapd/backend string HDB" | debconf-set-selections
RUN echo "slapd slapd/purge_database boolean true" | debconf-set-selections
RUN echo "slapd slapd/move_old_database boolean true" | debconf-set-selections
RUN echo "slapd slapd/allow_ldap_v2 boolean false" | debconf-set-selections
RUN echo "slapd slapd/no_configuration boolean false" | debconf-set-selections

RUN apt-get -y install slapd
#RUN dpkg-reconfigure slapd


# Change LDAP root password
RUN service slapd start && ldapsearch -H ldapi:// -LLL -Q -Y EXTERNAL -b "cn=config" "(olcRootDN=*)" dn olcRootDN olcRootPW > /tmp/oldpasswd.ldif

RUN head -1 /tmp/oldpasswd.ldif > /tmp/newpasswd.ldif
RUN echo "changetype: modify" >> /tmp/newpasswd.ldif
RUN echo "replace: olcRootPW" >> /tmp/newpasswd.ldif
RUN echo "olcRootPW: $(slappasswd -h {SSHA} -s ${LDAP_PASSWORD})" >> /tmp/newpasswd.ldif

RUN service slapd start && ldapmodify -H ldapi:// -Y EXTERNAL -f /tmp/newpasswd.ldif


# Install phpLDAPadmin
RUN apt-get -y install phpldapadmin

# Script to SED replace entries in phpLDAPadmin config file
COPY files/phpldapadmin.config.php.sh /tmp/
RUN /tmp/phpldapadmin.config.php.sh ${LDAP_DOMAIN} ${LDAP_ORG} ${LDAP_HOSTNAME}


#RUN dpkg-reconfigure tzdata


# Set FQDN for Apache Webserver
RUN echo "ServerName ${LDAP_HOSTNAME}" > /etc/apache2/conf-available/fqdn.conf
RUN sudo a2enconf fqdn


RUN apt-get clean


EXPOSE 389 636 80


COPY files/entrypoint.sh /root/

ENTRYPOINT ["/root/entrypoint.sh"]