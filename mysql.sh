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
dnf install mysql-server -y
validate $? " install my sql"

systemctl enable mysqld
validate $? " enable my sql"

systemctl start mysqld 
validate $? " start my sql" 

mysql_secure_installation --set-root-pass RoboShop@1
validate $? " set passwd"
