#!/bin/bash

# this script is used to create servers for implementing roboshop application

AMI_ID="ami-0220d79f3f480ecf5"
SG_ID="sg-0409773d198d0da2f"
ZONE_ID="Z0443476BR0YLVN9TX31"
SUBNET_ID="subnet-09332e278172839a0"
DOMAIN_NAME="chikoo.fun"

for instance in "$@" # mongodb redis mysql
do
    INSTANCE_ID=$(aws ec2 run-instances --image-id "$AMI_ID" --instance-type t3.micro --security-group-ids "$SG_ID" --subnet-id "$SUBNET_ID" --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)
    if [ "$instance" != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME"
    else
        IP=$(aws ec2 describe-instances --instance-ids "$INSTANCE_ID" --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        RECORD_NAME="$DOMAIN_NAME"
    fi
    echo "$instance: $IP"
    
    aws route53 list-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --query "ResourceRecordSets[?Name == '$RECORD_NAME.' && Type == 'A']"
    
    if [ $? -ne 0 ]; then
        echo "Record set $RECORD_NAME does not exist. Creating a new record set."
        aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE_ID \
        --change-batch '
        {
            "Comment": "Updating record set"
            ,"Changes": [{
            "Action"              : "UPSERT"
            ,"ResourceRecordSet"  : {
                "Name"              : "'"$RECORD_NAME"'"
                ,"Type"             : "A"
                ,"TTL"              : 1
                ,"ResourceRecords"  : [{
                    "Value"         : "'"$IP"'"
                }]
            }
            }]
        }
        '
    else
        echo "Record set $RECORD_NAME already exists. deleting existing record and creating new one."
        echo "Deleting existing record set $RECORD_NAME"
        aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE_ID \
        --change-batch "{
                    \"Changes\": [
               {
                     \"Action\": \"DELETE\",
                     \"ResourceRecordSet\": $(aws route53 list-resource-record-sets \
                      --hosted-zone-id $ZONE_ID \
                      --query "ResourceRecordSets[?Name == '$RECORD_NAME.']" \
                      --output json | jq '.[0]')
               }
            ]
        }"
        
        echo "Creating new record set $RECORD_NAME with IP $IP"
        aws route53 change-resource-record-sets \
        --hosted-zone-id $ZONE_ID \
        --change-batch '
        {
            "Comment": "Updating record set"
            ,"Changes": [{
            "Action"              : "UPSERT"
            ,"ResourceRecordSet"  : {
                "Name"              : "'"$RECORD_NAME"'"
                ,"Type"             : "A"
                ,"TTL"              : 1
                ,"ResourceRecords"  : [{
                    "Value"         : "'"$IP"'"
                }]
            }
            }]
        }
        '
    fi
done
