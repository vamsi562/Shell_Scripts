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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "Installing maven"

id roboshop &>>$LOG_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "Adding roboshop user"
else
    echo -e "roboshop user already exists ... $Y SKIPPING $N"
fi

mkdir -p /app  &>>$LOG_FILE

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "Downloading shipping code"

cd /app  
unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "Extracting shipping code"

mvn clean package &>>$LOG_FILE
VALIDATE $? "Building shipping code"

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "Renaming shipping jar file"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
VALIDATE $? "Copying shipping service file"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "Reloading systemd daemon"

systemctl enable shipping &>>$LOG_FILE
VALIDATE $? "Enabling shipping service"

systemctl start shipping &>>$LOG_FILE
VALIDATE $? "Starting shipping service"

dnf install mysql -y  &>>$LOG_FILE
VALIDATE $? "Installing MySQL"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql  &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
else
    echo -e "Shipping data is already loaded ... $Y SKIPPING $N"
fi

systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restarting shipping service"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo -e "Script executed in: $Y $TOTAL_TIME Seconds $N"