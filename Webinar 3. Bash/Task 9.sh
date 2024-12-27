#!/bin/bash

monitor_memory() {
    total_ram=$(free -m | awk '/^Mem:/{print $2}')
    used_ram=$(free -m | awk '/^Mem:/{print $3}')
    ram_usage_percentage=$((used_ram * 100 / total_ram))

    echo "Текущая загрузка памяти: $ram_usage_percentage%"

    if [ "$ram_usage_percentage" -gt 80 ]; then
        echo "Предупреждение! Загрузка памяти превысила 80%."
        echo "Наиболее ресурсоемкие процессы:"
        ps -eo pid,comm,%mem,%cpu --sort=-%mem | head -n 10
    fi
}

monitor_cpu() {
    cpu_average=$(uptime | awk -F'load average:' '{print $2}' | cut -d',' -f1 | xargs)
    echo "Загрузка процессора за последнюю минуту: $cpu_average"
}

monitor_disk() {
    echo "Статистика использования дискового пространства:"
    df -h | grep '^/dev/'
}

echo "Запуск мониторинга системных ресурсов:"
echo "---------------------------------------"
monitor_memory
echo
monitor_cpu
echo
monitor_disk
