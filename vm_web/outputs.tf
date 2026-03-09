output "db_cluster_info" {
  description = "Информация о кластере MySQL"
  value = {
    fqdn = yandex_mdb_mysql_cluster.my_cluster.host[0].fqdn
    id   = yandex_mdb_mysql_cluster.my_cluster.id
  }
}

output "db_user_info" {
  description = "Информация о пользователе БД"
  value = {
    name     = yandex_mdb_mysql_user.my_user.name
  }
  sensitive = true
}

output "db_database_name" {
  description = "Имя базы данных"
  value       = yandex_mdb_mysql_database.db.name
}

output "registry_info" {
  description = "Информация о Container Registry"
  value = {
    id   = yandex_container_registry.ufilin.id
    name = yandex_container_registry.ufilin.name
  }
}

output "vm_info" {
  description = "Информация о виртуальной машине"
  value = {
    id           = yandex_compute_instance.web.id
    public_ip    = yandex_compute_instance.web.network_interface.0.nat_ip_address
    private_ip   = yandex_compute_instance.web.network_interface.0.ip_address
    name         = yandex_compute_instance.web.name
  }
}