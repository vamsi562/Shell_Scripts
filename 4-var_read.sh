#!/bin/bash
# passing variables using read command

echo "enter your pin:"
read pin_number 

echo "your pin number is $pin_number"

# passing variables using read command with -s option to hide the input
echo "enter your name:"
read -s name
echo "your name is $name"