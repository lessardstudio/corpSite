#!/bin/bash

# Скрипт для создания "Виртуального IP" 10.60.0.3
# Это позволяет заходить на сайт по адресу http://10.60.0.3 (из подсети VPN),
# даже если сам контейнер находится в сети 172.25.0.0/24.

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)"
  exit 1
fi

VIRTUAL_IP="10.60.0.3"
DOCKER_IP="172.25.0.2"

echo "Configuring Virtual IP $VIRTUAL_IP -> $DOCKER_IP..."

# 1. Добавляем IP на loopback интерфейс (чтобы сервер "считал" этот IP своим)
if ip addr show lo | grep -q "$VIRTUAL_IP"; then
    echo "IP $VIRTUAL_IP already exists on lo"
else
    echo "Adding $VIRTUAL_IP to loopback..."
    ip addr add $VIRTUAL_IP/32 dev lo
fi

# 2. Настраиваем NAT (переадресацию)
# OUTPUT: Для трафика, который генерируется самим сервером (например, Hysteria/Xray proxy)
iptables -t nat -C OUTPUT -d $VIRTUAL_IP -p tcp --dport 80 -j DNAT --to-destination $DOCKER_IP:80 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Adding NAT rule (OUTPUT)..."
    iptables -t nat -A OUTPUT -d $VIRTUAL_IP -p tcp --dport 80 -j DNAT --to-destination $DOCKER_IP:80
else
    echo "NAT rule (OUTPUT) already exists."
fi

# PREROUTING: Если вдруг трафик приходит не через прокси, а маршрутизируется ядром (tun -> docker)
iptables -t nat -C PREROUTING -d $VIRTUAL_IP -p tcp --dport 80 -j DNAT --to-destination $DOCKER_IP:80 2>/dev/null
if [ $? -ne 0 ]; then
    echo "Adding NAT rule (PREROUTING)..."
    iptables -t nat -A PREROUTING -d $VIRTUAL_IP -p tcp --dport 80 -j DNAT --to-destination $DOCKER_IP:80
else
    echo "NAT rule (PREROUTING) already exists."
fi

# 3. Сохранение правил (опционально, зависит от ОС)
if command -v netfilter-persistent >/dev/null; then
    netfilter-persistent save
fi

echo "Done! You can now access http://$VIRTUAL_IP via VPN."
