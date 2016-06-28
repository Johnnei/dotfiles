#!/bin/sh

if [ $# -ne 1 ]; then
	echo "Syntax: generate-key.sh <keyname>"
	exit 1
fi

ssh-keygen -t rsa -b 4096 -C $USER_EMAIL -f ~/.ssh/$1

