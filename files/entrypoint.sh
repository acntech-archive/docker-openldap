#!/bin/bash

SERVICES="cron rsyslog slapd apache2"

for srv in ${SERVICES}; do
	update-rc.d ${srv} defaults
	update-rc.d ${srv} enable
	service ${srv} start
done

tail -f /var/log/sldapd.log