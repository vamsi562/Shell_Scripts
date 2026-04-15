#!/bin/bash

# this script demonstrates about colors in bash scripting

R="\e[31m]"
G="\e[32m]"
Y="\e[33m]"
W="\e[0m]"

echo -e "$R This is red color.${W}"
echo -e "$G This is green color.${W}"
echo -e "$Y This is yellow color.${W}"