#!/bin/bash

# this script is used to install servers for implementing roboshop application

AMI_ID="ami-0220d79f3f480ecf5"
INSTANCE_TYPE="t3.micro"
SECURITY_GROUP_ID="sg-03d2125bf6ee50b73"
Zone_ID="Z0443476BR0YLVN9TX31"
Domain_Name="chikoo.fun"

for i in $@; do
    TAG_NAME="roboshop-$i"
    echo "Creating EC2 instance for $i with tag $TAG_NAME..."
    Instance_ID=$(aws ec2 run-instances \
        --image-id "$AMI_ID" \
        --instance-type "$INSTANCE_TYPE" \
        --security-group-ids "$SECURITY_GROUP_ID" \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$TAG_NAME}]" \
        --query 'Instances[0].InstanceId' \
    --output text)
    # Get Private IP
    if [ $i != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$i.$DOMAIN_NAME" # mongodb.chikoo.fun
    else
        IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        RECORD_NAME="$DOMAIN_NAME" # chikoo.fun
    fi
    echo "$i: $IP"
    # Create Route53 Record
    echo "Creating Route53 record for $i with IP $IP..."
    aws route53 change-resource-record-sets \
    --hosted-zone-id "$Zone_ID" \
    --change-batch '
    {
        "Comment": "Updating record set"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$RECORD_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP'"
            }]
        }
        }]
    }
    '
done