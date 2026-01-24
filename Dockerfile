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


EXPOSE 80

# Используем entrypoint для запуска ZT + App
ENTRYPOINT ["./entrypoint.sh"]
