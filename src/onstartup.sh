#!/bin/bash

rm update-route53.ip
rm update-route53.hcid

accountId="$1"

if [ ! -z "$2" ]
then
    data=`cat $2`
else
    data=$(curl -s http://169.254.169.254/latest/user-data)
fi

echo data = $data

if [[ $data != alias=* ]]
then
    echo Invalid user data
    exit 1
fi

while read -r line; do
    echo $line
    if [[ $line == domain=* ]];then
        domainSettings=$(echo $line | cut -f2 -d=)
        echo domain settings = $domainSettings
        zoneId=$(echo $domainSettings | cut -f1 -d\|)
        echo zoneId = $zoneId
        domain=$(echo $domainSettings | cut -f2 -d\|)
        echo domain = $domain
        ipType=$(echo $domainSettings | cut -f3 -d\|)
        echo ipType = $ipType
        hcType=$(echo $domainSettings | cut -f4 -d\|)
        echo hcType = $hcType
        hcPort=$(echo $domainSettings | cut -f5 -d\|)
        echo hcPort = $hcPort
        topic=$(echo $domainSettings | cut -f6 -d\|)
        echo topic = $topic
        ./update-route53.sh $zoneId $domain $ipType $hcType $hcPort $accountId $topic
    fi
done <<< "$data"









