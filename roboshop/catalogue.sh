#!/bin/bash
trap '"echo -e script failed at line no: $LINENO, command: $BASH_COMMAND"' ERR

USERID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/shell-roboshop"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
MONGODB_HOST="mongodb.chikoo.fun"
SCRIPT_DIR=$PWD
mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE

if [ $USERID -ne 0 ]; then
    echo -e "$R Error: run this script as root user $N" | tee -a $LOG_FILE
    exit 1
fi

VALIDATE(){ # functions receive inputs through args just like shell script args
    if [ $1 -ne 0 ]; then
        echo -e "$2 ... $R FAILURE $N" | tee -a $LOG_FILE
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N" | tee -a $LOG_FILE
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "Disable NodeJS module"

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "Enable NodeJS 20 module"

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "Installing NodeJS"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Adding roboshop user"
else
    echo -e "roboshop user already exists ... $Y SKIPPING $N"
fi

mkdir -p /app

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip 
cd /app 
unzip /tmp/catalogue.zip

npm install &>>$LOG_FILE
VALIDATE $? "Installing NodeJS dependencies"

cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service 
VALIDATE $? "Copying catalogue systemd file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reloading systemd"

systemctl enable catalogue &>>$LOG_FILE
VALIDATE $? "Enabling catalogue service"

systemctl start catalogue &>>$LOG_FILE
VALIDATE $? "Starting catalogue service"

cp $SCRIPT_DIR/mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "Adding Mongo repo"

dnf install mongodb-mongosh -y &>>$LOG_FILE
VALIDATE $? "Installing MongoDB Shell"


INDEX=$(mongosh $MONGODB_HOST --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host $MONGODB_HOST </app/db/master-data.js &>>$LOG_FILE
    VALIDATE $? "Load catalogue products"
else
    echo -e "Catalogue products already loaded ... $Y SKIPPING $N"
fi

systemctl restart catalogue &>>$LOG_FILE
VALIDATE $? "Restarted catalogue"