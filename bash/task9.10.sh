#!/bin/bash

while true; do
    read -p "Введите команду: " command

    case $command in
        "Дата")
            echo "Текущая дата: $(date +"%Y-%m-%d %H:%M:%S")"
            ;;
        "Выход")
            echo "Выход из программы"
            break
            ;;
        *)
            echo "Неизвестная команда"
            ;;
    esac
done
