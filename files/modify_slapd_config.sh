#!/bin/bash

if [ "$#" -ne 1 ]; then
	echo "The script needs 1 argument(s)"
	echo "Call with: $0 <LDAP_PASSWORD>"
	exit 1
fi

LDAP_PASSWORD="$1"
OLD_PASSWORD_LDIF=/tmp/oldpasswd.ldif
NEW_PASSWORD_LDIF=/tmp/newpasswd.ldif

service slapd start
ldapsearch -H ldapi:// -LLL -Q -Y EXTERNAL -b "cn=config" "(olcRootDN=*)" dn olcRootDN olcRootPW > ${OLD_PASSWORD_LDIF}

head -1 ${OLD_PASSWORD_LDIF} > ${NEW_PASSWORD_LDIF}
echo "changetype: modify" >> ${NEW_PASSWORD_LDIF}
echo "replace: olcRootPW" >> ${NEW_PASSWORD_LDIF}
echo "olcRootPW: $(slappasswd -h {SSHA} -s ${LDAP_PASSWORD})" >> ${NEW_PASSWORD_LDIF}

ldapmodify -H ldapi:// -Y EXTERNAL -f ${NEW_PASSWORD_LDIF}

rm ${OLD_PASSWORD_LDIF} ${NEW_PASSWORD_LDIF}