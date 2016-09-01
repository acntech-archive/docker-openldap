#!/bin/bash

service cron start
service rsyslog start
service slapd start
service apache2 start

#update-rc.d cron defaults
#update-rc.d cron enable

#update-rc.d rsyslog defaults
#update-rc.d rsyslog enable

#update-rc.d slapd defaults
#update-rc.d slapd enable

#update-rc.d apache2 defaults
#update-rc.d apache2 enable

tail -f /var/log/sldapd.log