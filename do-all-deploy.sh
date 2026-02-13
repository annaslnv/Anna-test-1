#!/bin/bash
# Один скрипт: копирует ключ (один раз введи пароль root), деплоит проект, настраивает nginx.
# Запуск: bash do-all-deploy.sh

set -e
KEY="$HOME/.ssh/id_rsa_server_88"
SERVER="root@88.216.70.147"
SITE_DIR="/var/www/Anna-test-1"

echo "=== 1. Проверка ключа ==="
if [ ! -f "$KEY" ]; then
  echo "Ключ не найден: $KEY"
  exit 1
fi

echo "=== 2. Копирование ключа на сервер (если ещё не копировали — введи пароль root один раз) ==="
ssh-copy-id -i "${KEY}.pub" -o StrictHostKeyChecking=no "$SERVER" 2>/dev/null || true

echo "=== 3. Подключение к серверу и деплой ==="
ssh -i "$KEY" -o StrictHostKeyChecking=no "$SERVER" bash -s << 'REMOTE'
set -e
SITE_DIR="/var/www/Anna-test-1"
echo "Установка nginx и git..."
apt-get update -qq && apt-get install -y -qq nginx git >/dev/null 2>&1
echo "Клонирование/обновление репозитория..."
if [ -d "$SITE_DIR/.git" ]; then
  cd "$SITE_DIR" && git pull -q origin main
else
  rm -rf "$SITE_DIR" 2>/dev/null || true
  git clone -q https://github.com/annaslnv/Anna-test-1.git "$SITE_DIR"
fi
echo "Настройка nginx..."
cat > /etc/nginx/sites-available/anna-test-1 << 'NGINX'
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    root /var/www/Anna-test-1;
    index index.html;
    location / {
        try_files $uri $uri/ =404;
    }
}
NGINX
ln -sf /etc/nginx/sites-available/anna-test-1 /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default 2>/dev/null || true
nginx -t -q && systemctl reload nginx
echo "Готово."
REMOTE

echo ""
echo "=== Деплой завершён. Сайт: http://88.216.70.147 ==="
echo "Для HTTPS: настрой домен (A-запись на 88.216.70.147), затем на сервере:"
echo "  ssh -i $KEY $SERVER"
echo "  bash /var/www/Anna-test-1/ssl-on-server.sh твой-домен.ru"
