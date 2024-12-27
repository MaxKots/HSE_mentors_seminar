#!/bin/bash

# Проверка наличия аргумента
if [ "$#" -ne 1 ]; then
    echo "Ошибка: необходимо указать путь к директории для резервного копирования."
    echo "Пример использования: $0 /путь/к/директории"
    exit 1
fi

SOURCE="$1"

# Проверка существования и доступности директории
if [ ! -d "$SOURCE" ]; then
    echo "Ошибка: директория '$SOURCE' не найдена."
    exit 1
fi

# Создание директории для резервного копирования
BACKUP_PATH="${SOURCE}_backup_$(date +%Y%m%d)"
mkdir -p "$BACKUP_PATH"

# Лог-файл для записи результатов
LOGFILE="backup_log_$(date +%Y%m%d).log"
echo "Процесс резервного копирования начат..." > "$LOGFILE"

# Счетчик скопированных файлов
count=0

# Копирование файлов
for item in "$SOURCE"/*; do
    if [ -f "$item" ]; then
        filename=$(basename "$item")
        destination="$BACKUP_PATH/backup_$(date +%Y%m%d)_$filename"
        cp "$item" "$destination"
        echo "Копирование: $item -> $destination" >> "$LOGFILE"
        ((count++))
    fi
done

# Вывод результатов
if [ "$count" -gt 0 ]; then
    echo "Резервное копирование завершено. Всего скопировано файлов: $count." >> "$LOGFILE"
    echo "Резервное копирование прошло успешно. Скопировано файлов: $count."
    echo "Логи записаны в файл: $LOGFILE"
else
    echo "Нет файлов для резервного копирования в директории '$SOURCE'." >> "$LOGFILE"
    echo "Резервное копирование завершено. Файлы для копирования отсутствуют."
fi
