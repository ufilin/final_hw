module "vpc" {
  source = "./vpc"
  cloud_id = var.cloud_id
  folder_id = var.folder_id
  secret_key_file = var.secret_key_file
  vpc_name = var.vpc_name
  default_zone = var.default_zone
  default_cidr = var.default_cidr
}

module "vm_web" {
  source = "./vm_web"
  cloud_id = var.cloud_id
  folder_id = var.folder_id
  secret_key_file = var.secret_key_file
  default_zone = var.default_zone
  default_cidr = var.default_cidr
  subnet_id = module.vpc.vpc_details.subnet_ids[0]
  network_id = module.vpc.vpc_details.network_id
  security_group_ids = module.vpc.vpc_details.security_group_ids
  instance_name = "web"
  lockbox_secret_id = yandex_lockbox_secret.sa_key.id
  vm_service_account_id = yandex_iam_service_account.vm_sa.id
}

resource "yandex_lockbox_secret" "sa_key" {
  name        = "sa-key-secret"
  description = "Service account key for Docker auth"
}

resource "yandex_lockbox_secret_version" "sa_key_version" {
  secret_id = yandex_lockbox_secret.sa_key.id
  
  entries {
    key        = "key.json"
    text_value = file("/home/debian/.ssh/key.json")
  }
}

resource "yandex_iam_service_account" "vm_sa" {
  name        = "vm-lockbox-sa"
  description = "Service account for VM to access LockBox"
}

resource "yandex_lockbox_secret_iam_binding" "vm_sa_reader" {
  secret_id = yandex_lockbox_secret.sa_key.id
  role      = "lockbox.payloadViewer"
  members   = ["serviceAccount:${yandex_iam_service_account.vm_sa.id}"]
}