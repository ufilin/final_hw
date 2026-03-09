data "yandex_compute_image" "ubuntu" {
  family = var.vm_web_family
}

resource "yandex_compute_instance" "web" {
  hostname = "web"
  name        = "web"
  platform_id = var.vm_web_platform-id
  allow_stopping_for_update = var.allow_stopping_for_update
  resources {
    cores         = var.vms_resources["web"]["cores"]
    memory        = var.vms_resources["web"]["memory"]
    core_fraction = var.vms_resources["web"]["core_fraction"]
  }
  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu.image_id
      size = var.vms_resources["web"]["hdd_size"]
      type = var.vms_resources["web"]["hdd_type"]
    }
  }
  scheduling_policy {
    preemptible = var.vm_web_should_be_preemptible
  }
  network_interface {
    subnet_id = var.subnet_id
    nat       = var.vm_web_subnet_nat
    security_group_ids = var.security_group_ids
  }
  service_account_id = var.vm_service_account_id

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
    user-data = templatefile("${path.module}/cloud-init.yml", {
      DB_HOST     = yandex_mdb_mysql_cluster.my_cluster.host[0].fqdn
      DB_USER     = yandex_mdb_mysql_user.my_user.name
      DB_PASSWORD = var.auth_db["deb"]["password"]
      DB_NAME     = yandex_mdb_mysql_database.db.name
      REGISTRY_ID = yandex_container_registry.ufilin.id
      LOCKBOX_SECRET_ID = var.lockbox_secret_id
  })
  }
}