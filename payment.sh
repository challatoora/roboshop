#!/bin/bash

userid=$(id -u)
folder="/var/log/shell-roboshop"
log_file="$folder/$0.log"
Place=$PWD
Mongodb_host=mongodb.mreddy.online
Mysql_host=mysql.mreddy.online


if [ $userid -ne 0 ]; then
    echo -e "You are not a root user" | tee -a $log_file
    exit 1
fi

mkdir -p $folder

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$2 is failure" | tee -a $log_file
        exit 1
    else
        echo -e "$2 is success" | tee -a $log_file
    fi

}

dnf install python3 gcc python3-devel -y
validate $? "Installing maven"

id roboshop &>>$log_file
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
    validate $? "creating system user"
else
    echo "user alredy exist...skiping"
fi

mkdir -p /app &>>$log_file
validate $? " creating directory "

curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$log_file
validate $? " dowloading"

cd /app 
validate $? " moving app"

rm -rf /app/*
validate $? "removing existing code"

unzip /tmp/payment.zip &>>$log_file
validate $? " unzip the file"

cd /app 
pip3 install -r requirements.txt &>>$log_file
validate $? "installing pip"

cp $Place/payment.service /etc/systemd/system/payment.service &>>$log_file
validate $? " Created systemctl"

systemctl daemon-reload

systemctl enable payment  &>>$log_file
systemctl start payment
validate $? "starting payment"