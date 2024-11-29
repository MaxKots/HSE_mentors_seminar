#!/bin/bash

read -p "Путь к файлу: " file


# контрольная сумма
last_checksum=$(md5sum "$file" | awk '{ print $1 }')

echo "Начали отслеживание: $file"

while true; do
    sleep 10

    # Текущая сумма
    current_checksum=$(md5sum "$file" | awk '{ print $1 }')

    # Сравниваем суммы
    if [[ "$last_checksum" != "$current_checksum" ]]; then
        echo "Файл изменен: $file"
        # Обновляем старую сумму
        last_checksum=$current_checksum
    fi
done
