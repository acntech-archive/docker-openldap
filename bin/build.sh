#!/bin/bash

LDAP_DOMAIN=acntech.no
LDAP_ORG=AcnTech
LDAP_PASSWORD=welcome1
LDAP_HOSTNAME=ldap.acntech.internal

DIR="$( dirname $0 )"

docker build -t acntech/openldap:2.4.42 \
   --build-arg LDAP_DOMAIN=${LDAP_DOMAIN} \
   --build-arg LDAP_ORG=${LDAP_ORG} \
   --build-arg LDAP_PASSWORD=${LDAP_PASSWORD} \
   --build-arg LDAP_HOSTNAME=${LDAP_HOSTNAME} \
   ${DIR}/../