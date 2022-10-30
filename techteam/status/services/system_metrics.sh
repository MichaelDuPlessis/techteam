#!/bin/bash
#script to get system metrics

# system load
load=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {print usage}')

# amount of free memoery
free_mem=$(free -tk | grep -oP '\d+' | sed '12!d')

# free disk space
disk=$(df -Pk . | sed 1d | grep -v used | awk '{ print $4 "\t" }' | xargs)

# kernal version
kernal=$(uname -r)

# packages that can be upgraded
packages=$(apt list --upgradable | tail -n +2)

echo $load:$free_mem:$disk:$kernal:"$packages"
