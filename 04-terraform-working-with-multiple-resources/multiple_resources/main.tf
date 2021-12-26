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
variable "linode_label"{
    default = "web_server_01"
    type = string
}

resource "linode_stackscript" "website" {
  label = "website"
  description = "Installs a simple website"
  script =   templatefile("${path.module}/templates/simple_website/install.sh.tpl", {"${web_server}" = var.linode_label })
  images = ["linode/ubuntu21.04", "linode/ubuntu18.04"]
  rev_note = "initial version"
}

resource "linode_instance" "web" {
    label = var.linode_label
    image = "linode/ubuntu21.04"
    region = "us-east"
    type = "g6-nanode-1"
    root_pass = "WebsiteServer2022!@#"

    group = "webservers"
    tags = [ "terraform", "webserver" ]
    swap_size = 256
    private_ip = true
    stackscript_id = linode_stackscript.website.id
}

resource "linode_firewall" "webserver_firewall" {
  label = "web_firewall"
  tags  = ["terraform", "webservers"]

  inbound {
    label    = "allow-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "80"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["::/0"]
  }

  inbound_policy = "DROP"

  outbound_policy = "ACCEPT"

  linodes = [linode_instance.web.id]
}