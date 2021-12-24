provider "linode" {
  token = var.linode_token
}

resource "linode_instance" "web" {
  
  
  label     = var.instance_label
        image     = "linode/ubuntu18.04"
  region    = "us-central"
  type      = "g6-standard-1"
    root_pass = "terr4form-test"

  group      = "terraform"
  tags= ["terraform"]
  swap_size  =               256
                private_ip = true
}