#!/bin/bash
# Запускать на сервере (root) после входа по SSH:
# ssh -i ~/.ssh/id_rsa_server_88 root@88.216.70.147
# Затем: bash deploy-on-server.sh

set -e
SITE_DIR="/var/www/Anna-test-1"
NGINX_CONF="/etc/nginx/sites-available/anna-test-1"

echo "=== Установка nginx и git при необходимости ==="
command -v nginx >/dev/null 2>&1 || apt-get update && apt-get install -y nginx git

echo "=== Создание каталога и клонирование репозитория ==="
mkdir -p /var/www
if [ -d "$SITE_DIR/.git" ]; then
  cd "$SITE_DIR" && git pull origin main
else
  rm -rf "$SITE_DIR" 2>/dev/null || true
  git clone https://github.com/annaslnv/Anna-test-1.git "$SITE_DIR"
fi

echo "=== Настройка nginx ==="
cat > "$NGINX_CONF" << 'NGINX'
server {
    listen 80;
    listen [::]:80;
    server_name _;
    root /var/www/Anna-test-1;
    index index.html;
    location / {
        try_files $uri $uri/ =404;
    }
}
NGINX
ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

echo "=== Деплой завершён. Сайт доступен по http://88.216.70.147 ==="
echo "Для SSL: укажи домен (A-запись на 88.216.70.147) и запусти: bash ssl-on-server.sh твой-домен.ru"
