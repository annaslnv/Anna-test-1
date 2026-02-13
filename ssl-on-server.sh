#!/bin/bash
# Бесплатный SSL (Let's Encrypt). Запускать на сервере после настройки домена.
# Использование: bash ssl-on-server.sh твой-домен.ru

if [ -z "$1" ]; then
  echo "Укажи домен: bash ssl-on-server.sh example.com"
  exit 1
fi
DOMAIN="$1"
SITE_DIR="/var/www/Anna-test-1"
NGINX_CONF="/etc/nginx/sites-available/anna-test-1"

echo "=== Установка certbot ==="
apt-get update
apt-get install -y certbot python3-certbot-nginx

echo "=== Получение сертификата для $DOMAIN ==="
certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --register-unsafely-without-email --redirect

echo "=== Готово. Сайт доступен по https://$DOMAIN ==="
