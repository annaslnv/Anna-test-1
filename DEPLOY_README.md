# Деплой Anna-test-1 на сервер и SSL

## 1. GitHub

Репозиторий уже создан и файлы залиты:
- **Репозиторий:** https://github.com/annaslnv/Anna-test-1

Чтобы в дальнейшем пушить изменения с компьютера (после установки Xcode Command Line Tools или Git):

```bash
cd "/Users/annaslnv/Documents/курсор/tekhnika-event-wireframe"
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/annaslnv/Anna-test-1.git
git branch -M main
git push -u origin main
```
(При запросе пароля используй токен из ИНСТРУКЦИЯ_ПОДКЛЮЧЕНИЕ.md как пароль.)

---

## 2. Вход на сервер

По инструкции (ключ с твоего компьютера):

```bash
ssh -i ~/.ssh/id_rsa_server_88 root@88.216.70.147
```

Если ключ ещё не скопирован на сервер (один раз):

```bash
ssh-copy-id -i ~/.ssh/id_rsa_server_88.pub root@88.216.70.147
```

---

## 3. Деплой проекта на сервер

На сервере выполни (скопируй скрипт или команды по шагам):

**Вариант А — одной командой с твоего Mac (если SSH по ключу уже работает):**

```bash
scp -i ~/.ssh/id_rsa_server_88 deploy-on-server.sh root@88.216.70.147:/root/
ssh -i ~/.ssh/id_rsa_server_88 root@88.216.70.147 "bash /root/deploy-on-server.sh"
```

**Вариант Б — вручную на сервере:**

1. Войти: `ssh -i ~/.ssh/id_rsa_server_88 root@88.216.70.147`
2. Установить nginx и git (если нет):  
   `apt-get update && apt-get install -y nginx git`
3. Клонировать проект:  
   `git clone https://github.com/annaslnv/Anna-test-1.git /var/www/Anna-test-1`
4. Создать конфиг nginx `/etc/nginx/sites-available/anna-test-1`:

```nginx
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
```

5. Включить сайт и перезагрузить nginx:  
   `ln -sf /etc/nginx/sites-available/anna-test-1 /etc/nginx/sites-enabled/`  
   `rm -f /etc/nginx/sites-enabled/default`  
   `nginx -t && systemctl reload nginx`

После этого сайт открывается по адресу: **http://88.216.70.147**

---

## 4. Бесплатный SSL (Let's Encrypt)

SSL-сертификат выдаётся только на **доменное имя**, не на IP. Нужно:

1. Иметь домен (например, `anna-test.example.com` или купленный домен).
2. Настроить у регистратора **A-запись** этого домена на IP сервера: **88.216.70.147**.
3. На сервере выполнить (подставь свой домен):

```bash
apt-get install -y certbot python3-certbot-nginx
certbot --nginx -d твой-домен.ru --non-interactive --agree-tos --register-unsafely-without-email --redirect
```

После этого сайт будет открываться по **https://твой-домен.ru** с бесплатным SSL.

Файл `ssl-on-server.sh` в репозитории — тот же сценарий: скопируй его на сервер и запусти `bash ssl-on-server.sh твой-домен.ru`.

---

## 5. Обновление сайта после изменений

На сервере:

```bash
cd /var/www/Anna-test-1 && git pull origin main
```

Или добавь в cron задачу на ежедневный `git pull`.
