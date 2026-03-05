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

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_ed25519.pub")}"
  }
}
