#!/bin/bash

# Получаем ID реестра из Terraform output
REGISTRY_ID=$(terraform output -raw registry_id)

# Сборка образа
docker build -t cr.yandex/$REGISTRY_ID/my-web-app:v1 .

# Аутентификация в Yandex Container Registry
yc container registry configure-docker

# Push образа в реестр
docker push cr.yandex/$REGISTRY_ID/my-web-app:v1

echo "Образ успешно загружен в Container Registry"