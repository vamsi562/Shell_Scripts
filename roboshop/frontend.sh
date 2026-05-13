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
# MONGODB_HOST="mongodb.chikoo.fun"
SCRIPT_DIR=$PWD
START_TIME=$(date +%s)
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

dnf module list nginx -y &>>$LOG_FILE
VALIDATE $? "Checking nginx module availability"

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "Disabling nginx module"

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "Enabling nginx 1.24 module"

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "Installing nginx"

systemctl enable nginx  &>>$LOG_FILE
VALIDATE $? "Enabling nginx service"

systemctl start nginx   &>>$LOG_FILE
VALIDATE $? "Starting nginx service"

rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
VALIDATE $? "Cleaning nginx default content"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading frontend code"

cd /usr/share/nginx/html

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "Extracting frontend code"

cp $SCRIPT_DIR/nginx.conf /etc/nginx/default.d/nginx.conf &>>$LOG_FILE
VALIDATE $? "Copying nginx configuration file"

systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "Restarting nginx service"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N" #