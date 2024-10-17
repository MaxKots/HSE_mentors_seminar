read -p "Введи путь: " dir && for file in "$dir"/*; do mv "$file" "$dir/backup_$(basename "$file")"; done
