#!/bin/bash
read -p "Введите имя файла: " file && read -p "Введите слово для поиска: " word && echo $(grep -o -i "$word" "$file" | wc -l)

