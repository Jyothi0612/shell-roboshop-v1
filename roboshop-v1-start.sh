#!/bin/bash

for instance in $@
do
    instance_name="roboshop-$instance"
    echo "Processing start for: $instance_name"

    # 1. Find the Instance ID 
    instance_id=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=$instance_name" "Name=instance-state-name,Values=stopped" \
        --query "Reservations[*].Instances[*].InstanceId" \
        --output text)

    # Check if a stopped instance was actually found
    if [ -z "$instance_id" ]; then
        echo "No stopped instance found with name: $instance_name"
        continue
    fi

    echo "Found $instance_name ID: $instance_id"

    # 2. Start the instance
    aws ec2 start-instances --instance-ids $instance_id > /dev/null
    if [ $? -ne 0 ]; then
        echo "Failed to start $instance_name"
        continue
    fi

    # 3. Wait until it is running, then show its IPs
    aws ec2 wait instance-running --instance-ids $instance_id
    ips=$(aws ec2 describe-instances --instance-ids $instance_id \
        --query "Reservations[*].Instances[*].[PrivateIpAddress,PublicIpAddress]" \
        --output text)
    echo "Started $instance_name ($instance_id) - private/public IP: $ips"
done