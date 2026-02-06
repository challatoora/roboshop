#!/bin/bash

userid=$(id -u)
folder="/var/log/shell-roboshop"
log_file="$folder/$0.log"
Place=$PWD
Mongodb_host=mongodb.mreddy.online


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

dnf module disable nodejs -y &>>$log_file

dnf module enable nodejs:20 -y &>>$log_file

if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$log_file
    validate $? "creating system user"
else
    echo "user alredy exist...skiping"
fi

mkdir -p /app &>>$log_file
validate $? " creating directory "

curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip   &>>$log_file
validate $? " dowloading"

cd /app 
validate $? " moving app"

rm -rf /app/*
validate $? "removing existing code"

unzip /tmp/user.zip &>>$log_file
validate $? " unzip the file"

npm install
validate $? " insatalling"

cp $Place/user.service /etc/systemd/system/user.service &>>$log_file
validate $? " Created systemctl"

systemctl daemon-reload

systemctl enable user 

systemctl start user
validate $? "starting enableing th euser"