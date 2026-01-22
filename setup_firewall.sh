#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root (sudo)"
  exit 1
fi

echo "Configuring firewall for Public Access (Port 80)..."

# 1. UFW (Uncomplicated Firewall) - Common on Ubuntu
if command -v ufw >/dev/null; then
    echo "Found UFW. Allowing port 80..."
    ufw allow 80/tcp
    ufw reload
    echo "UFW status:"
    ufw status | grep 80
fi

# 2. Iptables (Generic Linux)
if command -v iptables >/dev/null; then
    echo "Found iptables. Adding rule..."
    # Check if rule exists to avoid duplicates
    if ! iptables -C INPUT -p tcp --dport 80 -j ACCEPT 2>/dev/null; then
        iptables -I INPUT -p tcp --dport 80 -j ACCEPT
        echo "Iptables rule added."
    else
        echo "Iptables rule already exists."
    fi
    
    # Try to save rules (distro dependent)
    if command -v netfilter-persistent >/dev/null; then
        netfilter-persistent save
    elif [ -d /etc/iptables ]; then
        iptables-save > /etc/iptables/rules.v4
    fi
fi

# 3. Check for listening ports
echo "Checking listening ports..."
if command -v ss >/dev/null; then
    ss -tulnp | grep :80
elif command -v netstat >/dev/null; then
    netstat -tulnp | grep :80
fi

echo "Done. Please also check your VPS Provider Firewall (AWS Security Group, DigitalOcean Firewall, etc)."
