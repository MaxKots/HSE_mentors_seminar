#!/bin/bash

echo "Enter your number:"
read Number
    if ((Number > 0)); then
        echo "Положительное"
        while (( i < Number )); do
            ((i++))
            echo "$i"
        done
    elif ((Number < 0)); then
        echo "Отрицательное"
    else
        echo "Ноль"
    fi
