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
    dnf module disable nginx -y
    dnf module enable nginx:1.24 -y
    dnf install nginx -y
    validate $? " installing nginix"

    systemctl enable nginx 
    systemctl start nginx 
    validate $? " enable and start "

    rm -rf /usr/share/nginx/html/* 
    validate $? " remove default content"

    curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip

    cd /usr/share/nginx/html 
    unzip /tmp/frontend.zip
    validate $? " unzip"

    cp $Place nginx.conf /etc/nginx/nginx.conf

    systemctl restart nginx 
