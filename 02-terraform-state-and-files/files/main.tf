/*
provider "linode" {
  token = "don'tusehardcodedsecrets"
}
*/

provider "linode" {
  token = var.linode_token
}