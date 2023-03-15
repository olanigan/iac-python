terraform {
    required_version = ">= 0.15"
    required_providers {
        linode = {
            source = "linode/linode"
            version = "1.25.0"
        }
    }

    backend "s3" {
        skip_credentials_validation = true
        skip_region_validation = true
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

    provisioner "remote-exec" {
        connection {
            host = "${self.ip_address}"
            type = "ssh"
            user = "root"
            password = "${var.root_user_pw}"
        }

        inline = [
            "sudo apt-get update",
            "curl -fsSL https://get.docker.com -o get-docker.sh",
            "sudo sh get-docker.sh"
        ]
    }
}
