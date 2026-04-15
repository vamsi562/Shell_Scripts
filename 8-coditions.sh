#!/bin/bash

# this script demonstrates about conditions in bash

Number=$1

echo "The number is: $Number"
if [ $(($Number % 2)) -eq 0 ]; then
    echo "$Number is an even number."
else
    echo "$Number is an odd number."
fi

echo "please enter another number: "
read AnotherNumber
if [ $AnotherNumber -gt 0 ]; then
    echo "$AnotherNumber is a positive number."
elif [ $AnotherNumber -lt 0 ]; then
    echo "$AnotherNumber is a negative number."
else
    echo "$AnotherNumber is zero."
fi