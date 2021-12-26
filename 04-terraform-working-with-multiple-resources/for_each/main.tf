terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "1.25.0"
    }
  }
}

provider "linode" {
  token = var.linode_token
}

variable "web_servers" {

  description = "All of our servers"
  type = map(object({

    label     = string
    image     = string
    region    = string
    type      = string
    root_pass = string

    group      = string
    tags       = list(string)
    swap_size  = number
    private_ip = bool

  }))

  default = {
    "web" = {
      group      = "web-servers"
      image      = "linode/ubuntu18.04"
      label      = "web-server"
      private_ip = false
      region     = "us-central"
      root_pass  = "terr4form-test-web"
      swap_size  = 256
      tags = [
        "terraform",
        "db"
      ]
      type = "g6-standard-1"
    },
    "db" = {
      group      = "db-servers"
      image      = "linode/ubuntu20.04"
      label      = "db-server"
      private_ip = true
      region     = "us-east"
      root_pass  = "terr4form-test-db"
      swap_size  = 256
      tags = [
        "terraform",
        "db"
      ]
      type = "g6-standard-1"
    }
  }


}

resource "linode_instance" "servers" {
  for_each = var.web_servers

  label     = each.value.label
  image     = each.value.image
  region    = each.value.region
  type      = each.value.type
  root_pass = each.value.root_pass

  group      = each.value.group
  tags       = each.value.tags
  swap_size  = each.value.swap_size
  private_ip = each.value.private_ip
}