#!/bin/bash

# Проверка на root права (нужны для привязки IP и порта 80)
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт с правами root (sudo)"
  exit 1
fi

# 1. Остановка Docker контейнеров (чтобы освободить порт и IP если были конфликты)
echo "Stopping Docker containers..."
docker-compose down

# 2. Настройка сетевого интерфейса (Alias IP)
# Добавляем IP 10.60.0.3 на интерфейс loopback (lo), чтобы сервер принимал трафик на этот IP
TARGET_IP="10.60.0.3"
if ip addr show lo | grep -q "$TARGET_IP"; then
    echo "IP $TARGET_IP already exists on lo"
else
    echo "Adding $TARGET_IP to loopback interface..."
    ip addr add $TARGET_IP/32 dev lo
fi

# 3. Установка зависимостей
echo "Installing dependencies..."
# Проверяем наличие python3-venv
if ! dpkg -s python3-venv >/dev/null 2>&1; then
    apt-get update && apt-get install -y python3-venv
fi

if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install -r requirements.txt

# 4. Запуск приложения
echo "Starting Flask application on $TARGET_IP:80..."
echo "Press Ctrl+C to stop."
# Мы запускаем на 0.0.0.0, но так как 10.60.0.3 теперь принадлежит хосту,
# обращения к 10.60.0.3 будут обрабатываться.
python app.py
