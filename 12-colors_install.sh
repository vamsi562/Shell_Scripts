#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
W="\e[0m"

if [ $(id -u) -ne 0 ]; then
    echo -e "${R}You need root access to run this script.${W}"
    exit 1
fi

validate_install() {
    if [ $1 -ne 0 ]; then
        echo "$R Software $2 installation was failure.$W"
        exit 1
    else
        echo "$G Software $2 installation was successful.$W"
    fi
}

dnf list installed mysql
if [ $? -ne 0 ]; then
    echo -e "${Y}MySQL is not installed. Installing MySQL...${W}"
    dnf install mysql -y
    validate_install $? "MySQL"
else
    echo -e "${G}MySQL is already installed.${W}"
fi

dnf list installed nginx
if [ $? -ne 0 ]; then
    echo -e "${Y}Nginx is not installed. Installing Nginx...${W}"
    dnf install nginx -y
    validate_install $? "Nginx"
else
    echo -e "${G}Nginx is already installed.${W}"
fi  

dnf list installed python3
if [ $? -ne 0 ]; then
    echo -e "${Y}Python 3 is not installed. Installing Python 3... ${W}"
    dnf install python3 -y
    validate_install $? "Python 3"
else
    echo -e "${G}Python 3 is already installed.${W}"
fi  