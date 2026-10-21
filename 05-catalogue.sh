#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/roboshop"
logs_file="${logs_folder}/${0}.log"
domain_name="agenticengg.online"
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

dnf module disable nodejs -y &>> $logs_file
dnf module enable nodejs:24 -y &>> $logs_file
dnf install nodejs -y &>> $logs_file
validate $? "Enable and installing nodejs 24"

id roboshop &>> $logs_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>> $logs_file
    validate $? "Creating system user"
else
    echo -e "$(timestamp) [INFO] System user roboshop already exist...${Y}SKIPPING${N}"
fi

mkdir -p /app
validate $? "Creating app directory"

curl -L -o /tmp/catalogue.zip https://raw.githubusercontent.com/daws-92s/roboshop-documentation/refs/heads/main/artifacts/catalogue-v4.zip &>> $logs_file
validate $? "Downloading catalogue"

cd /app
unzip /tmp/catalogue.zip &>> $logs_file
validate $? "Unzipping catalogue"

npm install &>> $logs_file
validate $? "Install dependencies"

sed -i "s/DOMAIN_NAME/$domain_name" catalogue.service
cp catalogue.service /etc/system.d/system/catalogue.service

systemctl daemon-reload &>> $logs_file
systemctl enable catalogue &>> $logs_file
systemctl start catalogue &>> $logs_file
validate $? "$(timestamp) [INFO] Enable and start catalogue service"


echo "$(timestamp) [INFO] Script completed in $SECONDS seconds"
echo "$(timestamp) [INFO] ==== Script completed execution ====" | tee -a $logs_file