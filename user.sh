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

dnf module disable nodejs -y

dnf module enable nodejs:20 -y

useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop

mkdir /app 

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip 
cd /app 
unzip /tmp/user.zip
