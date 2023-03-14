terraform {
 required_version = ">= 0.15"
 required_providers {
    linode = {
        source = "linode/linode"
        version = "1.25.0"
    }
 }

 }

provider "linode" {
    token = var.linode_pat_token
    }
resource "linode_instance" "cfe-pyapp" {
    count = "1"
    image = "linode/ubuntu20.04"
    label = "pyapp-${count.index + 1}"
    group = "Iac-Learner"
    region = "us-east"
    type = "g6-nanode-1"
    authorized_keys = [ var.authorized_key ]
    root_pass = var.root_user_pw
    tags = [ "python", "cfe" ]
    }
