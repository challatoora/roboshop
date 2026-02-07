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
cp $place/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
validate $? " copiying the rabbirmq repo"

dnf install rabbitmq-server -y
validate $? " installing rabbitmq"

systemctl enable rabbitmq-server
validate $? " enable server"

systemctl start rabbitmq-server
validate $? "start server"

rabbitmqctl add_user roboshop roboshop123
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*"
validate $? " adduser and give permission"
