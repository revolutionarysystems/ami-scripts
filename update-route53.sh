#!/bin/bash

# Script taken from http://willwarren.com/2014/07/03/roll-dynamic-dns-service-using-amazon-route53/

# Hosted Zone ID e.g. BJBK35SKMM9OE
ZONEID="$1"

# The CNAME you want to update e.g. hello.example.com
RECORDSET="$2"

# The type of IP. private or public
IPTYPE="$3"

# The type if health check
HCTYPE="$4"

# The port to perform the health check on
HCPORT="$5"

# More advanced options below
# The Time-To-Live of this recordset
TTL=300
# Change this if you want
COMMENT="Auto updating @ `date`"
# Change to AAAA if using an IPv6 address
TYPE="A"

PRIVATE="private"

if [ "$IPTYPE" == "$PRIVATE" ]
then
    IP=`curl -s http://instance-data/latest/meta-data/local-ipv4`
else
    IP=`curl -s http://instance-data/latest/meta-data/public-ipv4`
fi

function valid_ip()
{
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

IPFILE="update-route53.ip"
HOSTNAME=`hostname`

if ! valid_ip $IP; then
    echo "Invalid IP address: $IP"
    exit 1
fi

# Check if the IP has changed
if [ ! -f "$IPFILE" ]
    then
    touch "$IPFILE"
fi
if grep -Fxq "$IP" "$IPFILE"; then
    # code if found
    echo "IP is still $IP"
    exit 0
else
    echo "IP has changed to $IP"

    # Create health check
    RID=`uuidgen`
    aws route53 create-health-check --caller-reference $RID --health-check-config IPAddress=$IP,Port=$HCPORT,Type=$HCTYPE | grep "\"Id\":" | cut -f4 -d \" > update-route53.hcid
    HCID=`cat update-route53.hcid`
    echo HCID = $HCID

    # Fill a temp file with valid JSON
    TMPFILE=$(mktemp /tmp/temporary-file.XXXXXXXX)
    cat > ${TMPFILE} << EOF
    {
      "Comment":"$COMMENT",
      "Changes":[
        {
          "Action":"UPSERT",
          "ResourceRecordSet":{
            "ResourceRecords":[
              {
                "Value":"$IP"
              }
            ],
            "Name":"$RECORDSET",
            "Type":"$TYPE",
            "TTL":$TTL,
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

    # Clean up
    rm $TMPFILE
fi

# All Done - cache the IP address for next time
echo "$IP" > "$IPFILE"
