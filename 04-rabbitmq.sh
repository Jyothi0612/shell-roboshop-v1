#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $user_id -ne 0 ]; then
    echo "Please run this script with sudo access"
    exit 1
fi

mkdir -p $logs_folder

timestamp() {
    date "+%F %T"
}

validate() {
    if [ $1 != 0 ]; then
        echo -e "$(timestamp) [ERROR] ${2}..${R}Failed${N}" | tee -a $logs_file
    else
        echo -e "$(timestamp) [INFO] ${2}..${G}Success${N}" | tee -a $logs_file
    fi
}

echo "$(timestamp) [INFO] ==== Script started execution ====" | tee -a $logs_file

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? "Adding rabbitmq repo"

dnf install erlang rabbitmq-server -y &>> logs_file
validate $? "Installing RabbitMQ server"

systemctl enable rabbitmq-server &>> logs_file
systemctl start rabbitmq-server &>> logs_file
validate $? "Starting and enabling RabbitMQ server"

rabbitmqctl list_users | grep -qw "roboshop11"
if [ $? -ne 0]; then
    rabbitmqctl add_user roboshop roboshop123 &>> logs_file
    validate $? "Creating RabbitMQ user for Roboshop"
else
    echo -e "$(timestamp) [INFO] RabbitMQ user already exist...${Y}SKIPPING${N}"
fi

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> logs_file
validate $? "Setting the permissions for RabbitMQ"

echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
echo "$(timestamp) [INFO] ==== Script completed execution ====" | tee -a $logs_file
