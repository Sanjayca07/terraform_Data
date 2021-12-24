provider "linode" {
  token = "$LINODE_TOKEN"
}

data "linode_instances" "imported_instance"{
    filter {
    name = "label"
    values = ["import-server"]
  }
}

output "data_linode_ip" {
  value = data.linode_instances.imported_instance.ip_address
}