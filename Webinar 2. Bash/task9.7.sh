#!/bin/bash

# Токен и id
API_TOKEN="Мой_токен"
CHAT_ID="370892233"
MESSAGE="Привет, Макс Коцюба сделал задание 9.7"

# URL для отправки
URL="https://api.telegram.org/bot$API_TOKEN/sendMessage"

curl -s -X POST "$URL" -d "chat_id=$CHAT_ID&text=$MESSAGE"

echo "Отправил сообщение!"
