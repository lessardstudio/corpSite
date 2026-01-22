#!/bin/bash

# 1. Запуск ZeroTier в фоновом режиме
echo "Starting ZeroTier..."
zerotier-one -d

# Ждем инициализации
sleep 3

# 2. Подключение к сети (если ID передан)
if [ -n "$ZT_NETWORK_ID" ]; then
    echo "Joining ZeroTier Network: $ZT_NETWORK_ID"
    zerotier-cli join "$ZT_NETWORK_ID"
else
    echo "WARNING: ZT_NETWORK_ID not set. ZeroTier will not join any network."
fi

# 3. Вывод Node ID для авторизации
echo "------------------------------------------------"
echo "ZeroTier Node ID:"
zerotier-cli info | cut -d' ' -f3
echo "------------------------------------------------"

# 4. Запуск основного приложения
echo "Starting Flask App..."
exec python app.py
