#!/bin/bash

prefix_hello () {
    echo "Hello $1"
}

add_two_num(){
    local sum=$(($1+$2))
    echo sum of $1 and $2 is $sum
}

prefix_hello "Yolo man" 

add_two_num '2' '3'
