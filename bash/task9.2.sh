#!/bin/bash
read -p "первое число: " a
read -p "второе число: " b

#не люблю -lt и -gt
if [ "$a" \> "$b" ]; then
    echo "$a больше $b"
elif [ "$a" \< "$b" ]; then
    echo "$a меньше $b"
else
    echo "$a равно $b"
fi
