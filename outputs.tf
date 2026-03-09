output "db_cluster_fqdn" {
  description = "FQDN кластера MySQL"
  value       = module.vm_web.db_cluster_info.fqdn
}

output "db_cluster_id" {
  description = "ID кластера MySQL"
  value       = module.vm_web.db_cluster_info.id
}

output "db_user_name" {
  description = "Имя пользователя БД"
  value       = module.vm_web.db_user_info.name
  sensitive   = true
}

output "db_database_name" {
  description = "Имя базы данных"
  value       = module.vm_web.db_database_name
}

output "db_connection_string" {
  description = "Строка подключения к БД"
  value       = "mysql://${module.vm_web.db_user_info.name}@${module.vm_web.db_cluster_info.fqdn}:3306/${module.vm_web.db_database_name}"
  sensitive   = true
}

output "registry_id" {
  description = "ID Container Registry"
  value       = module.vm_web.registry_info.id
}

output "registry_name" {
  description = "Имя Container Registry"
  value       = module.vm_web.registry_info.name
}

output "web_vm_public_ip" {
  description = "Публичный IP веб-сервера"
  value       = module.vm_web.vm_info.public_ip
}

output "web_vm_private_ip" {
  description = "Приватный IP веб-сервера"
  value       = module.vm_web.vm_info.private_ip
}

output "web_vm_id" {
  description = "ID виртуальной машины"
  value       = module.vm_web.vm_info.id
}

output "web_vm_name" {
  description = "Имя виртуальной машины"
  value       = module.vm_web.vm_info.name
}

output "lockbox_secret_id" {
  description = "Registry iNFO id"
  value = module.vm_web.registry_info.id
  }
output "lockbox_secret_name" {
  description = "Registry iNFO name"
  value = module.vm_web.registry_info.name
  }
