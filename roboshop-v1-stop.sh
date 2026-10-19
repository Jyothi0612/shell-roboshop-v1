#!/bin/bash

for instance in $@
do
    instance_name="roboshop-$instance"
    echo "Processing stop for: $instance_name"

    # 1. Find the Instance ID using its unique Name tag
    instance_id=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=$instance_name" "Name=instance-state-name,Values=running,pending" \
        --query "Reservations[*].Instances[*].InstanceId" \
        --output text)

    # Check if a running instance was actually found
    if [ -z "$instance_id" ]; then
        echo "No running instance found with name: $instance_name"
        continue
    fi

    echo "Found $instance_name ID: $instance_id"

    # 2. Stop the instance
    aws ec2 stop-instances --instance-ids $instance_id
    echo "Stopped $instance_name ($instance_id)"
done
