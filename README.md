# final_hw

---

## ✅ Выполненные задания

### Задание 1. Инфраструктура в Yandex Cloud

<p align="center">
  <img src="screenshots/final_hw-1.png" width="800">
</p>  

📸 СКРИНШОТ 1: Вставьте здесь скриншот вывода команд, показывающий созданные ресурсы в Yandex Cloud

### Задание 2. Установка Docker и Docker Compose через cloud-init

Проверка на ВМ:

bash
docker --version
docker-compose --version
groups ubuntu | grep docker
docker ps

<p align="center">
  <img src="final_hw-2.png" width="800">
</p>  

📸 СКРИНШОТ 2: Вставьте здесь скриншот результата выполнения команд на ВМ, подтверждающий установку Docker и запуск контейнера

### Задание 3. Dockerfile и Container Registry

Проверка образа в registry:

bash
yc container image list --registry-id $(terraform output -raw registry_id)

<p align="center">
  <img src="final_hw-3.png" width="800">
</p>  

📸 СКРИНШОТ 3: Вставьте здесь скриншот процесса сборки образа и вывода команды проверки образа в registry

### Задание 4. Связка приложения с БД

bash
# Получить IP виртуальной машины
terraform output web_vm_public_ip

# Проверить эндпоинты
curl http://<IP-адрес>/
curl http://<IP-адрес>/health
curl http://<IP-адрес>/db-test

<p align="center">
  <img src="final_hw-4.1.png" width="800">
</p>  

📸 СКРИНШОТ 4: Вставьте здесь скриншот вывода curl команд, показывающих успешную работу приложения

<p align="center">
  <img src="final_hw-4.2.png" width="800">
</p>  

📸 СКРИНШОТ 5: Вставьте здесь скриншот открытого в браузере приложения по публичному IP-адресу

Задание 5*. LockBox (бонус)
Создание секрета в LockBox:

<p align="center">
  <img src="final_hw-5.1.png" width="800">
</p>  

📸 СКРИНШОТ 6: Вставьте здесь скриншот создания секрета в LockBox и вывода команды yc lockbox secret list

<p align="center">
  <img src="final_hw-5.2.png" width="800">
</p>  

📸 СКРИНШОТ 7: Вставьте здесь скриншот успешного выполнения docker login на ВМ
