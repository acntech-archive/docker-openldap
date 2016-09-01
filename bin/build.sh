#!/bin/bash

LDAP_DOMAIN=acntech.no
LDAP_ORG=AcnTech
LDAP_HOSTNAME=ldap.acntech.internal
LDAP_PASSWORD=welcome1

DIR="$( dirname $0 )"

docker build -t acntech/openldap:2.4.42 \
   --build-arg LDAP_DOMAIN=${LDAP_DOMAIN} \
   --build-arg LDAP_ORG=${LDAP_ORG} \
   --build-arg LDAP_HOSTNAME=${LDAP_HOSTNAME} \
   --build-arg LDAP_PASSWORD=${LDAP_PASSWORD} \
   ${DIR}/../