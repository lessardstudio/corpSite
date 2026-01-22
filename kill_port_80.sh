#!/bin/bash

# Скрипт для принудительного освобождения порта 80
# Используйте, если хотите включить проброс портов в docker-compose.yml

if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт с правами root (sudo)"
  exit 1
fi

echo "Checking for processes on port 80..."

# Попытка найти процесс
PID=$(lsof -t -i:80)

if [ -z "$PID" ]; then
    echo "Port 80 is free."
else
    echo "Found process(es) on port 80: $PID"
    echo "Killing..."
    kill -9 $PID
    echo "Done."
fi

# Также проверяем, не запущен ли наш run_native.sh (python)
pkill -f "python app.py"
echo "Ensured python app is stopped."
