#!/bin/bash
date
rm update-route53.ip
accountId="$1"
puppethost="$2"
echo puppethost = $puppethost
if [ ! -z "$3" ]
then
    data=`cat $3`
else
    data=$(curl http://169.254.169.254/latest/user-data)
fi
echo data = $data
alias=$(echo $data | cut -f1 -d\|)-$(uuidgen)
echo alias = $alias
zoneId=$(echo $data | cut -f2 -d\|)
echo zoneId = $zoneId
domain=$(echo $data | cut -f3 -d\|)
echo domain = $domain
ipType=$(echo $data | cut -f4 -d\|)
echo ipType = $ipType
hcType=$(echo $data | cut -f5 -d\|)
echo hcType = $hcType
hcPort=$(echo $data | cut -f6 -d\|)
echo hcPort = $hcPort
topic=$(echo $data | cut -f7 -d\|)
echo topic = $topic
echo $alias > /etc/hostname
service hostname start
echo 127.0.0.1 $alias >> /etc/hosts
puppetip=$(host $puppethost | grep address | cut -f4 -d\ ) 
echo puppetip = $puppetip
echo $puppetip puppet >> /etc/hosts
service puppet stop
apt-get update
puppet agent -t
service puppet start
if [ ! -z "$zoneId" ]
then
    ./update-route53.sh $zoneId $domain $ipType $hcType $hcPort $accountId $topic
fi
