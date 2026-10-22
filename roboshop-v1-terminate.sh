#!/bin/bash

echo "These instances will be TERMINATED (permanently deleted): $@"
read -p "Are you sure? (yes/no): " answer
if [ "$answer" != "yes" ]; then
    echo "Cancelled"
    exit 0
fi

for instance in $@
do
    instance_name="roboshop-$instance"

    instance_id=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=$instance_name" "Name=instance-state-name,Values=running,pending,stopping,stopped" \
        --query "Reservations[*].Instances[*].InstanceId" \
        --output text)

    if [ -z "$instance_id" ]; then
        echo "No instance found with name: $instance_name"
        continue
    fi

    aws ec2 terminate-instances --instance-ids $instance_id > /dev/null
    if [ $? -ne 0 ]; then
        echo "Failed to terminate $instance_name"
        continue
    fi
    echo "Terminating $instance_name ($instance_id)"
done