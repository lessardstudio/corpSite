#!/bin/bash

# Проверка на root права
if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт с правами root (sudo)"
  exit 1
fi

echo "Setting up Native Environment..."

# 1. Остановка Docker контейнеров (на всякий случай)
echo "Stopping Docker containers..."
docker-compose down 2>/dev/null || true

# 2. Настройка IP 10.60.0.3 на loopback
TARGET_IP="10.60.0.3"
if ip addr show lo | grep -q "$TARGET_IP"; then
    echo "IP $TARGET_IP already exists on lo"
else
    echo "Adding $TARGET_IP to loopback interface..."
    ip addr add $TARGET_IP/32 dev lo
fi

# 3. ВАЖНО: Включение маршрутизации на localhost
# Некоторые системы не разрешают трафик с внешних IP на 127.0.0.1 по умолчанию.
# Мы включаем route_localnet, чтобы разрешить перенаправление.
sysctl -w net.ipv4.conf.all.route_localnet=1 > /dev/null
sysctl -w net.ipv4.conf.default.route_localnet=1 > /dev/null

# 4. Настройка IPTables для перенаправления
# Если приложение слушает на 0.0.0.0:80, оно должно принимать пакеты на 10.60.0.3.
# Но если Hysteria пытается подключиться к 127.0.0.1 (как видно из логов),
# нам нужно убедиться, что приложение действительно доступно там.
# Flask app.run(host='0.0.0.0') уже слушает везде.

# Однако, ошибка 'connect: connection refused' к 127.0.0.1:80 говорит о том,
# что Hysteria (или система) пытается соединиться с localhost, но порт закрыт
# или блокируется.

# Проверим, не занят ли порт другим процессом (например, nginx)
echo "Checking port 80..."
fuser -k 80/tcp 2>/dev/null || true

# 5. Установка и запуск
echo "Installing dependencies..."
if ! dpkg -s python3-venv >/dev/null 2>&1; then
    apt-get update && apt-get install -y python3-venv
fi

if [ ! -d "venv" ]; then
    python3 -m venv venv
fi
source venv/bin/activate
pip install -r requirements.txt

# 6. Запуск приложения
echo "Starting Flask application on 0.0.0.0:80..."
# Flask будет слушать на всех IP, включая 10.60.0.3 и 127.0.0.1
python app.py
