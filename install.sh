#!/bin/bash

cp -i .gitconfig ~/.gitconfig
cp -i .profile ~/.profile
cp -i .vimrc ~/.vimrc
cp -ir path-utils ~/path-utils

# Install IntelliJ Templates
cp -iR intellij/* ~/.IntelliJIdea2017.2