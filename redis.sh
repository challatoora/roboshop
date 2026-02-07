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

dnf module disable redis -y &>>$log_file
dnf module enable redis:7 -y &>>$log_file
validate $? "Enableing the redis"

dnf install redis -y 
validate $? "Intsalling the redis"

sed -i -e "s/127.0.0.1/0.0.0.0/g" -e "/protected-mode/ c protected-mode no" /etc/redis/redis.conf
validate $? "Allowing the remote connections"

systemctl enable redis 
systemctl start redis 
validate $? "Starting the redis"