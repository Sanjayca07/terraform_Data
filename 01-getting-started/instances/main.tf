provider "linode" {
  token = "$LINODE_TOKEN"
}

resource "linode_instance" "web" {
    label = "simple_instance"
    image = "linode/ubuntu18.04"
    region = "us-central"
    type = "g6-nanode-1"
    root_pass = "terr4form-test"

    group = "terraform"
    tags = [ "terraform" ]
    swap_size = 256
    private_ip = true
}