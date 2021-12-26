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

variable "web_servers" {
  description = "Number of Web Servers"
  default = 2
  type = number 
}

resource "linode_instance" "web" {
    count = var.web_servers

    label = "${var.instance_label}-${count.index}"
    image = "linode/ubuntu18.04"
    region = "us-central"
    type = "g6-standard-1"
    root_pass = "terr4form-test-${count.index}"

    group = "webservers"
    tags = [ "terraform", "webserver-${count.index}" ]
    swap_size = 256
    private_ip = true
}