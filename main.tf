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
  subnet_id = module.vpc.vpc_details.subnet_ids[0]
  security_group_ids = module.vpc.vpc_details.security_group_ids
  instance_name = "web"
  }