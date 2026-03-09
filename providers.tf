terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.190.0"
    }
  }
  required_version = "~>1.12.0"

  backend "s3" {
    shared_credentials_files = [ "~/netology/.aws/credentials" ]
    profile = "netology"
    bucket = "terstate"
    key    = "terraform.tfstate"
    region = "ru-central1"
    use_lockfile = true
    endpoints = {s3 = "https://storage.yandexcloud.net"    }
    skip_region_validation = true
    skip_credentials_validation = true
    skip_requesting_account_id = true
    skip_s3_checksum = true
}
}

provider "yandex" {
  #token     = var.token
  service_account_key_file = pathexpand(var.secret_key_file) 
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
}