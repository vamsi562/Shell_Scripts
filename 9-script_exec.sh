#!/bin/bash

# this script demonstrates installing packages if you user have root access

USERID=$(id -u)
if [ $USERID -ne 0 ]; then
    echo "You need root access to run this script."
    #exit 1
fi

dnf install python3 -y
echo "Python 3 has been installed successfully."

if [ $? -eq 0 ]; then
    echo "Python 3 installation was successful."
else
    echo "Python 3 installation failed."
fi