#!/bin/bash

# Скрипт для установки ZeroTier и подключения к сети

if [ "$EUID" -ne 0 ]; then
  echo "Пожалуйста, запустите скрипт с правами root (sudo)"
  exit 1
fi

# 1. Проверка/Установка ZeroTier
if ! command -v zerotier-cli &> /dev/null; then
    echo "ZeroTier не найден. Устанавливаем..."
    curl -s https://install.zerotier.com | bash
else
    echo "ZeroTier уже установлен."
fi

# 2. Запрос ID сети (если не передан аргументом)
NETWORK_ID=$1
if [ -z "$NETWORK_ID" ]; then
    echo -n "Введите ваш ZeroTier Network ID (16 символов): "
    read NETWORK_ID
fi

if [ -z "$NETWORK_ID" ]; then
    echo "Ошибка: ID сети не введен."
    exit 1
fi

# 3. Подключение к сети
echo "Подключаемся к сети $NETWORK_ID..."
zerotier-cli join $NETWORK_ID

# 4. Вывод информации для авторизации
NODE_ID=$(zerotier-cli info | cut -d' ' -f3)
echo ""
echo "========================================================"
echo "Готово! Ваш VPS подключился к сети."
echo "Ваш Node ID: $NODE_ID"
echo ""
echo "ВАЖНО: Теперь зайдите в панель управления ZeroTier (my.zerotier.com)"
echo "Найдите устройство с ID $NODE_ID и поставьте галочку 'Auth' (Авторизован)."
echo "========================================================"
