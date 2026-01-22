# IP Checker Website (Native / Non-Docker)

Простой веб-сайт на Python (Flask), отображающий IP-адреса пользователя.

**Режим работы:** Нативный запуск (без Docker).
**Сетевая конфигурация:** Приложение слушает на хосте, используя виртуальный IP `10.60.0.3`.

## 1. Запуск без Docker (Native)

Этот метод позволяет запустить сайт прямо на сервере, назначив ему IP `10.60.0.3`, чтобы сохранить совместимость с настройками вашего VPN.

### Требования
* Linux (Ubuntu/Debian)
* Python 3
* Root права (для настройки сети и порта 80)

### Инструкция

1. Сделайте скрипт исполняемым:
   ```bash
   chmod +x run_native.sh
   ```

2. Запустите скрипт:
   ```bash
   sudo ./run_native.sh
   ```

### Что делает скрипт?
1. Останавливает старые Docker контейнеры.
2. Добавляет IP `10.60.0.3` на интерфейс `lo` (Loopback). Это заставляет ваш сервер "считать" этот IP своим собственным.
3. Создает виртуальное окружение Python и устанавливает зависимости.
4. Запускает Flask приложение на порту 80.

## 2. Автозапуск (Systemd)

Если вы хотите, чтобы сайт работал в фоне и запускался после перезагрузки:

1. Создайте файл сервиса:
   ```bash
   nano /etc/systemd/system/ip-checker.service
   ```

2. Вставьте следующее содержимое (замените путь `/root/corpSite` на ваш реальный путь):
   ```ini
   [Unit]
   Description=IP Checker Website
   After=network.target

   [Service]
   Type=simple
   User=root
   WorkingDirectory=/root/corpSite
   # Добавляем IP перед запуском (на случай перезагрузки)
   ExecStartPre=/sbin/ip addr add 10.60.0.3/32 dev lo
   # Игнорируем ошибку, если IP уже есть
   ExecStartPre=-/bin/true
   ExecStart=/root/corpSite/venv/bin/python /root/corpSite/app.py
   Restart=always

   [Install]
   WantedBy=multi-user.target
   ```

3. Активируйте и запустите:
   ```bash
   systemctl daemon-reload
   systemctl enable ip-checker
   systemctl start ip-checker
   ```

## 3. Интеграция с VPN

Так как IP `10.60.0.3` теперь находится на самом сервере (на loopback интерфейсе), маршрутизация упрощается.
Hysteria2/Xray, работающие на этом же сервере, смогут обращаться к `10.60.0.3` напрямую.

*   Убедитесь, что `net.ipv4.ip_forward=1`.
*   Правила маршрутизации в клиенте остаются прежними (`IP-CIDR,10.60.0.0/24,PROXY`).
