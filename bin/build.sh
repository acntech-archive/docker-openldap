#!/bin/bash

LDAP_DOMAIN=acntech.no
LDAP_ORG=AcnTech
LDAP_HOSTNAME=ldap.acntech.internal
LDAP_PASSWORD=welcome1
DOCKER_IMAGE_NAME=acntech/openldap
DOCKER_IMAGE_VERSION=latest

DIR="$( dirname $0 )"

docker build -t ${DOCKER_IMAGE_NAME}:${DOCKER_IMAGE_VERSION} \
   --build-arg LDAP_DOMAIN=${LDAP_DOMAIN} \
   --build-arg LDAP_ORG=${LDAP_ORG} \
   --build-arg LDAP_HOSTNAME=${LDAP_HOSTNAME} \
   --build-arg LDAP_PASSWORD=${LDAP_PASSWORD} \
   ${DIR}/../