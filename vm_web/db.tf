resource "yandex_mdb_mysql_user" "my_user" {
  cluster_id = yandex_mdb_mysql_cluster.my_cluster.id
  name       = var.auth_db["deb"]["name"]
  password   = var.auth_db["deb"]["password"]

  permission {
    database_name = yandex_mdb_mysql_database.db.name
    roles         = ["ALL"]
  }

  permission {
    database_name = yandex_mdb_mysql_database.db.name
    roles         = ["ALL", "INSERT"]
  }

  /*connection_limits {
    max_questions_per_hour   = 10
    max_updates_per_hour     = 20
    max_connections_per_hour = 30
    max_user_connections     = 40
  }*/

  global_permissions = ["PROCESS"]

  authentication_plugin = "SHA256_PASSWORD"
}

resource "yandex_mdb_mysql_database" "db" {
  cluster_id = yandex_mdb_mysql_cluster.my_cluster.id
  name       = "db"
}

resource "yandex_mdb_mysql_cluster" "my_cluster" {
  name        = "db-cluster"
  environment = "PRESTABLE"
  network_id  = var.network_id
  version     = "8.0"

  resources {
    resource_preset_id = "b1.medium"
    disk_type_id       = var.vms_resources["db"]["hdd_type"]
    disk_size          = var.vms_resources["db"]["hdd_size"]
  }

  host {
    zone      = var.default_zone
    subnet_id = var.subnet_id
  }
}