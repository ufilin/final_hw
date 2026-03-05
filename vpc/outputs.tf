output "vpc_details" {
  description = "Details of the created VPC"
  value = {
    name           = var.vpc_name
    zone           = var.default_zone
    network_id     = yandex_vpc_network.develop.id
    subnet_ids     = [yandex_vpc_subnet.develop.id]
    security_group_ids = [yandex_vpc_security_group.web.id]
    v4_cidr_blocks = var.default_cidr
  }
}