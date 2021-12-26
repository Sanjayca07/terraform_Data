terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.25.0"
    }
  }
}

provider "linode" {
  token = var.linode_token
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