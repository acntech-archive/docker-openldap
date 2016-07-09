#!/bin/bash

LDAP_HOSTNAME=ldap.acntech.internal

docker run --name acntech-openldap -h ${LDAP_HOSTNAME} -p 389:389 -p 636:636 -p 28080:80 -it acntech/openldap:2.4.42