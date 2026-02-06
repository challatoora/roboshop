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
validate $? " disable the nodejs version"

dnf module enable nodejs:20 -y
validate $? " enable the  20 version"

dnf install nodejs -y
validate $? " installimg"

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    validate $? "creating system user"
else
    echo "user alredy exist...skiping"

mkdir /app 
validate $? " creating directory "

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
validate $? " dowloading"

cd /app 
validate $? " moving app"

rm -rf /app/*
validate $? "removing existing code"

unzip /tmp/catalogue.zip
validate $? " unzip the file"

npm install

cp $Place/catalogue service /etc/systemd/system/catalogue.service

systemctl daemon-reload
systemctl enable catalogue 
systemctl start catalogue
validate $? "starting catalogue" 

cp $PWD/mongo.repo /etc/yum.repos.d/mongo.repo
dnf install mongodb-mongosh -y

index=$(mongosh --host $Mongodb_host --quiet --evil  'db.getMongo().getDBNames().indexOf("catalogue")')
if [ $index -le 0 ]; then
    mongosh --host $Mongodb_host </app/db/master-data.js
    validate $? "Loading db"
else
    echo "products alredy loaded...skiping"


systemctl restart catalogue
validate $? "restarting catalogue" 
