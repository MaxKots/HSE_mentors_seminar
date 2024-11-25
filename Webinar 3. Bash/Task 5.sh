#!/bin/bash

# Запуск трех команд sleep с разными временами в фоновом режиме
echo "Запускаем три команды sleep с разными временами в фоновом режиме:"
sleep 25 &  # Задача 1
sleep 15 &  # Задача 2
sleep 18 &  # Задача 3

# Даем задачам время запуститься
sleep 1

# Показываем текущие фоновые задачи
echo "Текущие фоновые задачи (jobs):"
jobs

# Переводим первую задачу на передний план
echo "Переводим первую задачу (Job 1) на передний план (don't foget ctrl+Z):"
fg %1

# После завершения первой задачи, показываем оставшиеся фоновые задачи
echo "Текущие фоновые задачи (jobs) после завершения первой задачи:"
jobs

# Переводим вторую задачу на передний план

echo "Переводим вторую задачу (Job 2) на передний план (don't foget ctrl+Z):"
fg %2

# После завершения второй задачи, показываем оставшиеся фоновые задачи
echo "Текущие фоновые задачи (jobs) после завершения второй задачи:"
jobs

# Переводим третью задачу на передний план
echo "Переводим третью задачу (Job 3) на передний план (don't foget ctrl+Z):"
fg %3

echo "Конец"