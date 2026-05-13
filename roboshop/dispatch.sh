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

dnf install golang -y &>>$LOG_FILE
VALIDATE $? "Installing golang"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Adding roboshop user"
else
    echo -e "roboshop user already exists ... $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOG_FILE

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch-v3.zip  &>>$LOG_FILE
VALIDATE $? "Downloading dispatch code"

cd /app 

unzip /tmp/dispatch.zip &>>$LOG_FILE
VALIDATE $? "Extracting dispatch code"


go mod init dispatch &>>$LOG_FILE
VALIDATE $? "Initializing go module"

go get  &>>$LOG_FILE
VALIDATE $? "Downloading go dependencies"

go build &>>$LOG_FILE
VALIDATE $? "Building dispatch code"

cp $SCRIPT_DIR/dispatch.service /etc/systemd/system/dispatch.service &>>$LOG_FILE
VALIDATE $? "Copying dispatch service file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reloading systemd daemon"

systemctl enable dispatch  &>>$LOG_FILE
VALIDATE $? "Enabling dispatch service"

systemctl start dispatch &>>$LOG_FILE
VALIDATE $? "Starting dispatch service"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"