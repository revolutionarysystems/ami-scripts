#!/bin/bash

# Script taken from http://willwarren.com/2014/07/03/roll-dynamic-dns-service-using-amazon-route53/







COMMENT="Auto removing @ `date`"
# Change to AAAA if using an IPv6 address
TYPE="A"


HOSTNAME=`hostname`

while read line1 && read -u 3 line2; do
ZONEID=$(echo $line1 | cut -f1 -d\|)
RECORDSET=$(echo $line1 | cut -f2 -d\|)
IP=$(echo $line1 | cut -f3 -d\|)
HCID=$line2
echo Removing $IP with and Health Check $HCID

# Fill a temp file with valid JSON
TMPFILE=$(mktemp /tmp/temporary-file.XXXXXXXX)
cat > ${TMPFILE} << EOF
{
  "Comment":"$COMMENT",
  "Changes":[
    {
      "Action":"DELETE",
      "ResourceRecordSet":{
"ResourceRecords":[
              {
                "Value":"$IP"
              }
            ],

        "Name":"$RECORDSET",
        "Type":"$TYPE",
        "TTL": 300,
  "SetIdentifier": "$HOSTNAME",
"Weight": 1,
"HealthCheckId": "$HCID"
}
      }
  ]
}
EOF

# Update the Hosted Zone record
aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONEID \
    --change-batch file://"$TMPFILE"
echo ""

aws route53 delete-health-check --health-check-id $HCID

aws cloudwatch delete-alarms --alarm-names $HOSTNAME-hc --region us-east-1

# Clean up
rm $TMPFILE

done < update-route53.ip 3< update-route53.hcid

