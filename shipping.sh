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

dnf install maven -y
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

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$log_file
validate $? " dowloading"

cd /app 
validate $? " moving app"

rm -rf /app/*
validate $? "removing existing code"

unzip /tmp/shipping.zip &>>$log_file
validate $? " unzip the file"

cd /app 
mvn clean package 
validate $? "installing and building th eshipping"

mv target/shipping-1.0.jar shipping.jar 
validate $? "Moving and ranaming the shipping"

cp $Place/shipping.service /etc/systemd/system/shipping.service &>>$log_file
validate $? " Created systemctl"


dnf install mysql -y 
validate $? "installing mwsql"


mysql -h $Mysql_host -uroot -pRoboShop@1 < /app/db/schema.sql
mysql -h $Mysql_host -uroot -pRoboShop@1 < /app/db/app-user.sql 
mysql -h $Mysql_host -uroot -pRoboShop@1 < /app/db/master-data.sql


systemctl enable shipping 
systemctl start shipping
validate $? "Enableing and starting the shipping"