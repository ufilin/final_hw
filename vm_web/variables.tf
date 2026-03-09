variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "secret_key_file" {
  type        = string
  default     = "null"
  description = "Path to service account key file; https://cloud.yandex.ru/docs/iam/operations/service-account-key/create"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "default_cidr" {
  type        = list(string)
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "develop"
  description = "VPC network&subnet name"
}

variable "vm_db_name" {
  type        = string
  default     = "netology-develop-platform-db"
  description = "example vm_db_ prefix" 
}

variable "vm_web_family" {
  type        = string
  default     = "ubuntu-2004-lts"
  description = "Family of the image to use for the web VM"
}

variable "vm_web_platform-id" {
  type        = string
  default     = "standard-v1"
  description = "Platform ID for the web VM"
}

variable "allow_stopping_for_update" {
  type        = bool
  default     = true
  description = "Allow stopping for update"
}

variable "vm_web_should_be_preemptible" {
  type        = bool
  default     = true
  description = "Should the web VM be preemptible"
}

variable "vm_web_subnet_nat" {
  type        = bool
  default     = true
  description = "Should the web subnet have NAT"
}
variable "auth_db" {
  type = map(map(any))
  default = {
    "deb" = {
      "name" = "deb"
      "password" = "1234567890"
    }
  }
}

variable "vms_resources" {
  type = map(map(any))
  default = {
    "web" = {
      "cores" = 2
      "memory" = 1  
      "core_fraction" = 5
      "hdd_size" = 10
      "hdd_type" = "network-hdd"
    }
    "db" = {
      "hdd_size" = 10
      "hdd_type" = "network-hdd"
    }
  }
}

variable "labels" {
  type = string
  default = "owner=ufilin,env=develop"
}

variable "platform_id" {
  type        = string
  default     = "standard-v1"
  description = "Platform ID for the VMs"
}
variable "subnet_id" {
  description = "ID подсети для виртуальной машины"
  type        = string
}

variable "network_id" {
  description = "ID сети для виртуальной машины"
  type        = string
  }

variable "security_group_ids" {
  description = "ID групп безопасности"
  type        = list(string)
}

variable "instance_name" {
  description = "Имя инстанса"
  type        = string
  default     = "web"
}

variable "lockbox_secret_id" {
  description = "ID LockBox"
  type = string
}

variable "vm_service_account_id" {
  description = "ID сервисного аккаунта для ВМ"
  type        = string
}