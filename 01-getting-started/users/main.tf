provider "linode" {
  token = "$LINODE_TOKEN"
}

resource "linode_user" "Jeff" {
    username = "jeff_test"
    email = "jeff@jeff.io"
}