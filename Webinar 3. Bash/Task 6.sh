#!/bin/bash


exec 2>> error.log

cat < $1 >&2 
if [[ -f $1 ]]; then
    wc -l < $1 > output.txt
    echo "Результат подсчета строк записан в output.txt."
else
    echo "Файл $1 не найден, подсчет строк невозможен."
fi
