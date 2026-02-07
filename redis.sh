#!/bin/bash

userid=$(id -u)
folder="/var/log/shell-roboshop"
log_file="$folder/$0.log"


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
  validate $? " enable the redis 7"

  dnf install redis -y &>>$log_file
  validate $? " installing redis"

  sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf
  validate $? "allaowing remote connection"
  
  systemctl enable redis &>>$log_file
  systemctl start redis 
  validate $? "enable the redis"





