#!/bin/bash

#this is a simple bash file to demonstrate how to use special variables in bash
name1=$1
name2=$2
name3=$3

echo "the names of users are $@" # using $@ to print all the arguments passed to the script
echo "the names of users are $*" # using $* to print all the arguments passed to the script
echo "the name of the script is $0" #$0 - it will fetch the name of the script
echo "the number of arguments passed to the script is $#" #$# - it will fetch the number of arguments passed to the script
echo "current working directory is $PWD" #$PWD - it will fetch the current working directory
echo "the process id of the script is $$" #$$ - it will fetch the process id of the script
echo "the exit status of the last command is $?" #$? - it will fetch the exit status of the last command executed. 0 means success and any other value means failure.
echo "user is $USER" #$USER - it will fetch the username of the current user
echo "home directory is $HOME" #$HOME - it will fetch the home directory of the current user
echo "shell being used is $SHELL" #$SHELL - it will fetch the shell being used by the current user