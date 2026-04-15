#!/bin/bash

# this script demonstrates using functions to install multiple packages

if [ $(id -u) -ne 0 ]; then
    echo "You need root access to run this script."
    exit 1
fi

validate_install() {
    if [ $1 -eq 0 ]; then
        echo "$2 installation was successful."
    else
        echo "$2 installation failed."
    fi
}

dnf install nginx -y
validate_install $? "Nginx"

dnf install mysql -y
validate_install $? "MySQL"