#!/bin/bash
read -p "Введи имя директории: " DIR_NAME && tar -czf "$(basename архив)_$(date +%Y-%m-%d).tar.gz" -C "$(dirname "$DIR_NAME")" "$(basename "$DIR_NAME")"
