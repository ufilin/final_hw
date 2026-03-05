terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "~> 0.190.0"
    }
  }
  required_version = "~>1.12.0"
}

provider "yandex" {
  #token     = var.token
  service_account_key_file = pathexpand(var.secret_key_file) 
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}