#!/bin/bash

# Проверка наличия файла
if [ $# -ne 1 ]; then
    echo "Usage: $0 <filename>"
    exit 1
fi

FILENAME="$1"

# 1 Таска. Создать список всех файлов в текущей директории и их тимпами
echo "Список файлов в директории:"
for item in *; do
    if [ -d "$item" ]; then
        echo "$item: каталог"
    elif [ -f "$item" ]; then
        echo "$item: файл"
    elif [ -L "$item" ]; then
        echo "$item: символьная ссылка"
    else
        echo "$item: другой тип"
    fi
done

# 2 Таска. Проверка наличия определённого файла
if [ -e "$FILENAME" ]; then
    echo "Файл '$FILENAME' существует."
else
    echo "Файл '$FILENAME' не найден."
fi

# 3 Таска. Цикл for для вывода инфы о каждом файле
echo "Информация о каждом файле:"
for item in *; do
    if [ -e "$item" ]; then
        permissions=$(ls -l "$item" | cut -d ' ' -f 1)
        echo "$item: $permissions"
    fi
done
