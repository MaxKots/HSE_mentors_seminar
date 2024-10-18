#!/bin/bash

#гугл говорит, что нужен модуль inotifywait
read -p "Введи путь:" file

# Чексумма
last_checksum=$(md5sum "$file" | awk '{ print $1 }')

echo "Начало отслеживания в $file"

while true; do
    #Ждём 10 сек
    sleep 10

    # Текущая чексумма
    current_checksum=$(md5sum "$file" | awk '{ print $1 }')

    # Сравниваем чексуммы
    if [[ "$last_checksum" != "$current_checksum" ]]; then
        echo "Файл изменен: $file"
        # Обновляем старую чексумму
        last_checksum=$current_checksum
    fi
done
