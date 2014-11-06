#!/bin/bash

# Script taken from http://willwarren.com/2014/07/03/roll-dynamic-dns-service-using-amazon-route53/

# Hosted Zone ID e.g. BJBK35SKMM9OE
ZONEID="$1"

# The CNAME you want to update e.g. hello.example.com
RECORDSET="$2"

COMMENT="Auto removing @ `date`"
# Change to AAAA if using an IPv6 address
TYPE="A"



IP=`cat update-route53.ip`
HOSTNAME=`hostname`

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
"Weight": 1
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

# Clean up
rm $TMPFILE


