#!/bin/bash

LDAP_HOSTNAME=ldap.acntech.internal
DOCKER_CONTAINER_NAME=acntech-openldap
DOCKER_IMAGE_NAME=acntech/openldap

docker run --name ${DOCKER_CONTAINER_NAME} -h ${LDAP_HOSTNAME} -p 389:389 -p 636:636 -p 28080:80 -it --rm ${DOCKER_IMAGE_NAME}