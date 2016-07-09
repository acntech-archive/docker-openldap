#!/bin/bash

if [ "$#" -ne 3 ]; then
	echo "The script needs 3 arguments"
	echo "Call with: $0 <LDAP_DOMAIN> <LDAP_ORG> <LDAP_HOSTNAME>"
fi

LDAP_DOMAIN="$1"
LDAP_ORG="$2"
LDAP_HOSTNAME="$3"

LDAP_BASE=`echo "dc=${LDAP_DOMAIN}" | sed 's/\./,dc=/g'`
LDAP_SERVER_NAME="${LDAP_ORG} LDAP Server"

sed -i 's/\s*\$servers->setValue('\''server'\'','\''name'\'','\''.*'\'');\s*/$servers->setValue('\''server'\'','\''name'\'','\'"${LDAP_SERVER_NAME}"\'');/g' /etc/phpldapadmin/config.php

sed -i 's/\s*\$servers->setValue('\''server'\'','\''host'\'','\''.*'\'');\s*/$servers->setValue('\''server'\'','\''host'\'','\'"${LDAP_HOSTNAME}"\'');/g' /etc/phpldapadmin/config.php

sed -i 's/\s*\$servers->setValue('\''server'\'','\''base'\'',array('\''.*'\''));\s*/$servers->setValue('\''server'\'','\''base'\'',array('\'"${LDAP_BASE}"\''));/g' /etc/phpldapadmin/config.php

sed -i 's/\s*\$servers->setValue('\''login'\'','\''bind_id'\'','\''.*'\'');\s*/$servers->setValue('\''login'\'','\''bind_id'\'','\''cn=admin,'"${LDAP_BASE}"\'');/g' /etc/phpldapadmin/config.php

sed -i 's/\s*[#]*[\/\/]*\s*\$config->custom->appearance\['\''hide_template_warning'\''\]\s*=\s*false;\s*/$config->custom->appearance['\''hide_template_warning'\''] = true;/g' /etc/phpldapadmin/config.php
