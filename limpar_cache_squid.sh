#!/bin/bash
/etc/init.d/squid3 stop
DIR_LOG=/scripts/log/log_limpa_squid.log
rm -Rf /var/spool/squid3/* > $DIR_LOG
squid3 -z >> $DIR_LOG
/etc/init.d/squid3 start
