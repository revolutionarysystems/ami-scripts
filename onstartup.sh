#!/bin/bash
date
if [ ! -z "$1" ]
then
    data=`cat $1`
else
    data=$(curl http://169.254.169.254/latest/user-data)
fi
echo data = $data
alias=$(echo $data | cut -f1 -d\|)
echo alias = $alias
puppetmaster=$(echo $data | cut -f2 -d\|)
echo puppetmaster = $puppetmaster
zoneId=$(echo $data | cut -f3 -d\|)
echo zoneId = $zoneId
domain=$(echo $data | cut -f4 -d\|)
echo domain = $domain
ipType=$(echo $data | cut -f5 -d\|)
echo ipType = $ipType
echo $alias > /etc/hostname
service hostname start
echo 127.0.0.1 $alias >> /etc/hosts
echo $puppetmaster puppet >> /etc/hosts
service puppet stop
apt-get update
puppet agent -t
service puppet start
if [ ! -z "$zoneId" ]
then
    ./update-route53.sh $zoneId $domain $ipType
fi
