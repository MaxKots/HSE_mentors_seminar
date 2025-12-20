#!/bin/bash
read -p "Путь к логам:" directory

find "$directoryY" -type f -name "*.log" -printf '%T@ %p
' | sort -n | head -n 5 | cut -d' ' -f2-
