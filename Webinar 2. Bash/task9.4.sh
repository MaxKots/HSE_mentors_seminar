#!/bin/bash
read -p "введи хост:" URL
# Ping хоста
 
ping -c 1 $URL > /dev/null
if [ $? -eq 0 ]; then
    echo "$URL доступен"
else
    echo "$URL недоступен"
fi
