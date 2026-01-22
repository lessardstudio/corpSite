#!/bin/bash

# Скрипт для отмены изменений, внесенных setup_virtual_ip.sh

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)"
  exit 1
fi

VIRTUAL_IP="10.60.0.3"
DOCKER_IP="172.25.0.2"

echo "Cleaning up Virtual IP $VIRTUAL_IP..."

# 1. Удаляем IP с loopback интерфейса
if ip addr show lo | grep -q "$VIRTUAL_IP"; then
    echo "Removing $VIRTUAL_IP from loopback..."
    ip addr del $VIRTUAL_IP/32 dev lo
else
    echo "IP $VIRTUAL_IP not found on lo."
fi

# 2. Удаляем правила NAT (iptables)
echo "Removing iptables rules..."

# Удаляем из OUTPUT
while iptables -t nat -D OUTPUT -d $VIRTUAL_IP -p tcp --dport 80 -j DNAT --to-destination $DOCKER_IP:80 2>/dev/null; do
    echo "Deleted NAT rule (OUTPUT)"
done

# Удаляем из PREROUTING
while iptables -t nat -D PREROUTING -d $VIRTUAL_IP -p tcp --dport 80 -j DNAT --to-destination $DOCKER_IP:80 2>/dev/null; do
    echo "Deleted NAT rule (PREROUTING)"
done

# 3. Сохранение изменений (опционально)
if command -v netfilter-persistent >/dev/null; then
    netfilter-persistent save
fi

echo "Cleanup complete. Access via 10.60.0.3 is now disabled."
