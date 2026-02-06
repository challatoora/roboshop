#!/bin/bash

AMI_ID="ami-0220d79f3f480ecf5"
SECURITY_GROUP_IDS="sg-07a628098640c0e6c"
INSTANCE_TYPE="t3.micro"
Zone_ID="Z03767891OMNNRGY4CE9B"
Domain_Name="mreddy.online"

for instance in $@
do
    INSTANCE_ID=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --instance-type "$INSTANCE_TYPE" \
    --security-group-ids "$SECURITY_GROUP_IDS" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" \
    --query 'Instances[0].InstanceId' \
    --output text)

    if [ $instance=="frontend" ]; then
        IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PublicIpAddress' \
            --output text
        )
        Record_name="$Domain_Name"
        
        
    else
         
         IP=$(
            aws ec2 describe-instances \
            --instance-ids $INSTANCE_ID \
            --query 'Reservations[].Instances[].PrivateIpAddress' \
            --output text
        )
        Record_name="$instance.$Domain_Name"
    fi

        echo "ip address is : $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $Zone_ID \
    --change-batch '
    {
        "Changes": [
            {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "'$Record_name'",
                "Type": "A",
                "TTL": 1,
                "ResourceRecords": [
                {
                    "Value": "'$IP'"
                }
                ]
            }
            }
        ]
    }
    '
    echo "instance record updated: $instance"
    
done



