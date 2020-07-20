#!/bin/bash
service isc-dhcp-server stop
rm -rf /var/lib/dhcp/dhcpd.leases~
echo "" > /var/lib/dhcp/dhcpd.leases
service isc-dhcp-server start
