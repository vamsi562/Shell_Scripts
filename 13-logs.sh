#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

if [ $(id -u) -ne 0 ]; then
    echo -e "$R You need root access to run this script. $W"
    exit 1
fi

LOGS_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 ) #$0 - it will give script name
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log" # /var/log/shell-script/16-logs.log

mkdir -p $LOGS_FOLDER
echo "Script started executed at: $(date)" | tee -a $LOG_FILE
#tee -a : it shows the output on the terminal and also appends it to the log file

validate_install() {
    if [ $1 -ne 0 ]; then # $1 - value to this passed at runtime i.e during script execution
        echo -e "$R Software $2 installation was failure.$W"
        exit 1
    else
        echo -e "$G Software $2 installation was successful.$W"
    fi
}

dnf list installed mysql &>>$LOG_FILE # &>> : it appends both stdout and stderr to the log file
# Install if it is not found in the list of installed packages
if [ $? -ne 0 ]; then
    dnf install mysql -y &>>$LOG_FILE
    validate_install $? "MySQL"
else
    echo -e "MySQL already exist ... $Y SKIPPING $N" | tee -a $LOG_FILE
fi

dnf list installed nginx &>>$LOG_FILE
if [ $? -ne 0 ]; then
    dnf install nginx -y &>>$LOG_FILE
    validate_install $? "Nginx"
else
    echo -e "Nginx already exist ... $Y SKIPPING $N" | tee -a $LOG_FILE
fi

dnf list installed python3 &>>$LOG_FILE
if [ $? -ne 0 ]; then
    dnf install python3 -y &>>$LOG_FILE
    validate_install $? "Python3"
else
    echo -e "Python3 already exist ... $Y SKIPPING $N" | tee -a $LOG_FILE
fi