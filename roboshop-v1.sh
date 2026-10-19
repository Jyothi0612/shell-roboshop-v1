#!/bin/bash

ami_id="ami-0220d79f3f480ecf5"
instance_type="t3.micro"
domain_name="agenticengg.online"
hosted_zone_id="Z09464412E06R977EX6SZ"

for instance in $@
do
    echo "Creating instance: $instance"
done