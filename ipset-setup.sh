#!/bin/bash
#
# countries ipblocks -> ipset -> iptables = drop traffic from specified country
#

IPSET="ipset"
IPTABLES="iptables"
#SETNAME="ipblocks"
COUNTRYCODE="ccodes.list"

IPLIST="iplist"

command -v ipset >/dev/null 2>&1 || { echo "I require ipset but it not installed.  Aborting." >&2; exit 1; }

# ipset flush
ipset flush

while read CODE
do
    ipset create $CODE-set hash:net
    for IP in $(curl -s http://www.ipdeny.com/ipblocks/data/countries/$CODE.zone)
    do
	ipset add $CODE-set $IP
    done
    iptables -I INPUT -m set --match-set $CODE-set src -j DROP
done < $COUNTRYCODE
exit 0
