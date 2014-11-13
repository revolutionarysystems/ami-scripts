#!/bin/bash
date
if [ ! -z "$1" ]
then
    data=`cat $1`
else
    data=$(curl http://169.254.169.254/latest/user-data)
fi
echo data = $data
zoneId=$(echo $data | cut -f2 -d\|)
echo zoneId = $zoneId
domain=$(echo $data | cut -f3 -d\|)
echo domain = $domain
if [ ! -z "$zoneId" ]
then
    ./remove-from-route53.sh $zoneId $domain
fi
