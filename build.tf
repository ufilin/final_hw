resource "null_resource" "build_and_push_image" {
  depends_on = [
    module.vm_web
  ]

  triggers = {
    registry_id = module.vm_web.registry_info.id 
    dockerfile_hash = filesha1("${path.module}/app/dockerfile")
    requirements_hash = filesha1("${path.module}/app/requirements.txt")
    app_hash = filesha1("${path.module}/app/app.py")
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "🔨 Сборка Docker образа..."
      cd ${path.module}/app
      docker build -t cr.yandex/${module.vm_web.registry_info.id}/my-web-app:v1 .
      echo "✅ Образ собран: cr.yandex/${module.vm_web.registry_info.id}/my-web-app:v1"
    EOT
  }

  provisioner "local-exec" {
    command = <<EOT
      echo "🔑 Авторизация в Container Registry..."
      cat /home/debian/.ssh/key.json | docker login --username json_key --password-stdin cr.yandex
      
      echo "📤 Загрузка образа..."
      docker push cr.yandex/${module.vm_web.registry_info.id}/my-web-app:v1
      
      echo "✅ Образ успешно загружен!"
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "docker rmi cr.yandex/${self.triggers.registry_id}/my-web-app:v1 || true"
  }
}

output "image_uri" {
  value = "cr.yandex/${module.vm_web.registry_info.id}/my-web-app:v1"
}

output "registry_id_1" {
  value = module.vm_web.registry_info.id
}