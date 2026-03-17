# Итоговый проект: Развертывание web-приложения в Yandex Cloud

## 📋 Описание проекта
В рамках итогового проекта выполнено развертывание web-приложения в облачной инфраструктуре **Yandex Cloud** с использованием инструментов **Terraform**, **Docker** и **Docker Compose**.

---

## ✅ Выполненные задания

### Задание 1. Инфраструктура в Yandex Cloud

**Созданные ресурсы:**
- ✅ Virtual Private Cloud (VPC) `develop`
- ✅ Подсеть в зоне `ru-central1-a` с CIDR `10.0.1.0/24`
- ✅ Виртуальная машина `web` с публичным IP
- ✅ Группы безопасности (порты 22, 80, 443)
- ✅ Кластер Managed MySQL `db-cluster`
- ✅ Container Registry `ufilin-registry`
- ✅ Сервисный аккаунт для LockBox
- ✅ LockBox секрет для хранения ключа

**Команды для проверки:**
```bash
# Просмотр созданных ресурсов
yc compute instance list
yc managed-mysql cluster list
yc container registry list
yc lockbox secret list
📸 СКРИНШОТ 1: Вставьте здесь скриншот вывода команд, показывающий созданные ресурсы в Yandex Cloud

Задание 2. Установка Docker и Docker Compose через cloud-init
Что выполнено:

✅ Написан конфигурационный файл cloud-init.yml

✅ Docker и Docker Compose устанавливаются автоматически

✅ Пользователь ubuntu добавлен в группу docker

✅ Создана структура папок и файлов конфигурации

✅ Выполнена авторизация в Container Registry

✅ Создан скрипт инициализации базы данных

Фрагмент cloud-init.yml:

yaml
#cloud-config
package_update: true
packages:
  - docker.io
  - docker-compose
  - python3-pip
  - python3-mysql.connector

runcmd:
  - systemctl enable docker
  - systemctl start docker
  - usermod -aG docker ubuntu
  - mkdir -p /home/ubuntu/app
  - cat /home/ubuntu/key.json | docker login --username json_key --password-stdin cr.yandex
  - python3 /home/ubuntu/init_db.py
  - cd /home/ubuntu/app && docker-compose pull && docker-compose up -d
Проверка на ВМ:

bash
docker --version
docker-compose --version
groups ubuntu | grep docker
docker ps
📸 СКРИНШОТ 2: Вставьте здесь скриншот результата выполнения команд на ВМ, подтверждающий установку Docker и запуск контейнера

Задание 3. Dockerfile и Container Registry
Dockerfile:

dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

ENV PORT=5000
EXPOSE $PORT

CMD ["python", "app.py"]
requirements.txt:

text
flask==2.3.3
mysql-connector-python==8.1.0
Автоматизация в Terraform (build.tf):

hcl
resource "null_resource" "build_and_push_image" {
  depends_on = [yandex_container_registry.ufilin]

  triggers = {
    registry_id = yandex_container_registry.ufilin.id
    dockerfile_hash = filesha1("${path.module}/app/Dockerfile")
    requirements_hash = filesha1("${path.module}/app/requirements.txt")
  }

  provisioner "local-exec" {
    command = <<EOT
      cd ${path.module}/app
      docker build -t cr.yandex/${yandex_container_registry.ufilin.id}/my-web-app:v1 .
      cat /home/debian/.ssh/key.json | docker login --username json_key --password-stdin cr.yandex
      docker push cr.yandex/${yandex_container_registry.ufilin.id}/my-web-app:v1
    EOT
  }
}
Проверка образа в registry:

bash
yc container image list --registry-id $(terraform output -raw registry_id)
📸 СКРИНШОТ 3: Вставьте здесь скриншот процесса сборки образа и вывода команды проверки образа в registry

Задание 4. Связка приложения с БД
Код приложения (app.py):

python
from flask import Flask, jsonify
import mysql.connector
import os
import time

app = Flask(__name__)

DB_HOST = os.environ.get('DB_HOST')
DB_USER = os.environ.get('DB_USER')
DB_PASSWORD = os.environ.get('DB_PASSWORD')
DB_NAME = os.environ.get('DB_NAME')

def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            port=3306,
            connection_timeout=10
        )
        return connection
    except Exception as e:
        return None

@app.route('/')
def index():
    return jsonify({
        'message': 'Hello from Docker container!',
        'status': 'running',
        'db_configured': True
    })

@app.route('/health')
def health():
    return jsonify({'status': 'healthy'})

@app.route('/db-test')
def db_test():
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM messages")
        count = cursor.fetchone()[0]
        cursor.close()
        conn.close()
        return jsonify({
            'status': 'connected',
            'database': DB_NAME,
            'host': DB_HOST,
            'messages_count': count
        })
    return jsonify({'status': 'disconnected'}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 5000)))
docker-compose.yml:

yaml
version: '3.3'
services:
  web-app:
    image: cr.yandex/${REGISTRY_ID}/my-web-app:v1
    ports:
      - "80:5000"
    environment:
      - DB_HOST=${DB_HOST}
      - DB_PORT=3306
      - DB_USER=${DB_USER}
      - DB_PASSWORD=${DB_PASSWORD}
      - DB_NAME=${DB_NAME}
      - PORT=5000
    restart: unless-stopped
.env файл:

text
DB_HOST=rc1a-r7k64hp5hr45mbdm.mdb.yandexcloud.net
DB_USER=deb
DB_PASSWORD=1234567890
DB_NAME=db
REGISTRY_ID=crptlhfjd00crd128k04
PORT=5000
Проверка работы приложения:

bash
# Получить IP виртуальной машины
terraform output web_vm_public_ip

# Проверить эндпоинты
curl http://<IP-адрес>/
curl http://<IP-адрес>/health
curl http://<IP-адрес>/db-test
Ожидаемый результат:

json
{
  "db_configured": true,
  "message": "Hello from Docker container!",
  "status": "running"
}

{"status": "healthy"}

{
  "database": "db",
  "host": "rc1a-r7k64hp5hr45mbdm.mdb.yandexcloud.net",
  "messages_count": 1,
  "status": "connected"
}
📸 СКРИНШОТ 4: Вставьте здесь скриншот вывода curl команд, показывающих успешную работу приложения

📸 СКРИНШОТ 5: Вставьте здесь скриншот открытого в браузере приложения по публичному IP-адресу

Задание 5*. LockBox (бонус)
Создание секрета в LockBox:

hcl
resource "yandex_lockbox_secret" "sa_key" {
  name        = "sa-key-secret"
  description = "Service account key for Docker auth"
}

resource "yandex_lockbox_secret_version" "sa_key_version" {
  secret_id = yandex_lockbox_secret.sa_key.id
  entries {
    key        = "key.json"
    text_value = file(var.service_account_key_file)
  }
}
Получение ключа на ВМ через cloud-init:

bash
IAM_TOKEN=$(curl -s -H "Metadata-Flavor: Google" http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token | python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")

curl -s -H "Authorization: Bearer $IAM_TOKEN" \
  https://payload.lockbox.api.cloud.yandex.net/lockbox/v1/secrets/${LOCKBOX_SECRET_ID}/payload \
  | python3 -c "import sys, json; data=json.load(sys.stdin); print([e['textValue'] for e in data['entries'] if e['key']=='key.json'][0])" \
  > /home/ubuntu/key.json

cat /home/ubuntu/key.json | docker login --username json_key --password-stdin cr.yandex
📸 СКРИНШОТ 6: Вставьте здесь скриншот создания секрета в LockBox и вывода команды yc lockbox secret list

📸 СКРИНШОТ 7: Вставьте здесь скриншот успешного выполнения docker login на ВМ

🚀 Инструкция по развертыванию
Клонировать репозиторий

bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
Настроить переменные

bash
export YC_TOKEN=$(yc iam create-token)
export YC_CLOUD_ID=$(yc config get cloud-id)
export YC_FOLDER_ID=$(yc config get folder-id)
Применить Terraform

bash
terraform init
terraform apply -auto-approve
Проверить работу

bash
IP=$(terraform output -raw web_vm_public_ip)
curl http://$IP/
📊 Выходные данные
bash
$ terraform output

web_vm_public_ip = "51.250.xxx.xxx"
registry_id = "crptlhfjd00crd128k04"
db_cluster_fqdn = "rc1a-r7k64hp5hr45mbdm.mdb.yandexcloud.net"
lockbox_secret_id = "e6q20hl774v7v6chioi2"
image_uri = "cr.yandex/crptlhfjd00crd128k04/my-web-app:v1"
📸 СКРИНШОТ 8: Вставьте здесь скриншот вывода terraform output

🛠️ Используемые технологии
Terraform — управление инфраструктурой

Yandex Cloud — облачная платформа

Docker / Docker Compose — контейнеризация

Python / Flask — веб-приложение

MySQL — база данных

LockBox — хранение секретов

👨‍💻 Автор
Ufilin
GitHub: @yourusername

✅ Заключение
Все задания итогового проекта выполнены успешно:

Инфраструктура развернута в Yandex Cloud

Docker и Docker Compose установлены через cloud-init

Dockerfile создан, образ загружен в Container Registry

Приложение в контейнере подключено к БД

LockBox интеграция реализована (бонус)
