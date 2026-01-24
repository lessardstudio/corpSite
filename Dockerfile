FROM python:3.9-slim

WORKDIR /app

# Установка зависимостей для ZeroTier (curl, gnupg)
RUN apt-get update && apt-get install -y curl gnupg iproute2 && \
    curl -s https://install.zerotier.com | bash && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

# Генерируем self-signed SSL сертификат
RUN mkdir -p /app/certs && \
    openssl req -x509 -newkey rsa:4096 -nodes \
    -out /app/certs/cert.pem \
    -keyout /app/certs/key.pem \
    -days 365 \
    -subj "/C=RU/ST=Moscow/L=Moscow/O=CorpVPN/CN=ipchecker.corp.clan"

EXPOSE 80 443

# Используем entrypoint для запуска ZT + App
ENTRYPOINT ["./entrypoint.sh"]
