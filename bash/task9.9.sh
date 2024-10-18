#!/bin/bash

# Функция фонового запуска
run_command() {
    "$@" &   # фон
    pid=$!   # PID
    echo "PID процесса: $pid"
    wait $pid  # Ждем завершения
}

commands=()

echo "Введите команды для запуска или 'exit' для завершения:"

while true; do
    read -p "> " cmd
    if [[ "$cmd" == "exit" ]]; then
        break
    fi
    commands+=("$cmd")
done

# Параллельный запуск
for command in "${commands[@]}"; do
    run_command $command &
done

# Ждем завершения
wait

echo "Все команды завершены."
