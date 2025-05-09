#!/bin/bash

apt update -y # По дефолту оновлюємо сервер
apt install -y docker.io git # Встановлюємо Docker та git

sudo usermod -aG docker ubuntu # Додаємо користувача ubuntu до групи docker
newgrp docker # Застосовуємо зміни групи без перезавантаження

git clone https://github.com/alexandermoroz01/test-docker-nginx.git     # Клонуємо репозиторій з Dockerfile

sudo systemctl enable docker    # Додаємо Docker до автозапуску
sudo systemctl start docker   # Запускаємо Docker

cd test-docker-nginx    # Переходимо в папку з Dockerfile
docker build -t test-app .  # Створюємо образ test-app з Dockerfile
docker run -d -p 80:80 --name test-app --restart unless-stopped test-app    # Запускаємо контейнер test-app з образом test-app, мапимо порт 80 на 80, додаємо автозапуск
docker ps -a    # Перевіряємо, чи запустився контейнер
