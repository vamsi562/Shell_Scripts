#!/bin/bash

# this script demonstrates about datatypes in bash

no1=10
no2=20

$sum=$(($no1 + $no2))

echo "The sum of $no1 and $no2 is: ${sum}"

name="John Doe"
echo "My name is $name"

Names=("$1" "$2" "$3")
echo "The names are: ${Names[0]}, ${Names[1]}, and ${Names[2]}"
echo " names are ${Names[@]}"
echo "Number of names: ${#Names[@]}" # #-to get no of elements in array