#!/bin/bash

# Make a new repo on my pi.



echo "Not even sure if this works" >&2
exit 1



if [ $# -ne 1 ]; then
    echo "Expected name of repo to make." 1>&2
    exit 1
fi

ssh git@pi "mkdir ~/repos/$1 && git init --bare ~/repos/$1"
