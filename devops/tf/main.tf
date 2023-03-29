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
    count = "2"
    image = "linode/ubuntu20.04"
    label = "pyapp-${count.index + 1}"
    group = "iac-learner"
    region = "us-east"
    type = "g6-nanode-1"
    authorized_keys = [ var.authorized_key ]
    root_pass = var.root_user_pw
    tags = [ "python", "terra" ]

    #  Provision docker install script
    provisioner "file" {
        connection {
            host = "${self.ip_address}"
            type = "ssh"
            user = "root"
            password = "${var.root_user_pw}"
        }

        source = "${local.root_dir}/bootstrap-docker.sh"
        destination = "/tmp/bootstrap-docker.sh"
    }

     #  Execute docker install script
    provisioner "remote-exec" {
        connection {
            host = "${self.ip_address}"
            type = "ssh"
            user = "root"
            password = "${var.root_user_pw}"
        }

        inline = [
            "chmod +x /tmp/bootstrap-docker.sh",
            "sudo sh /tmp/bootstrap-docker.sh",
            "mkdir -p /var/www/src/",
        ]
    }

    #  Provision App source code
    provisioner "file" {
        connection {
            host = "${self.ip_address}"
            type = "ssh"
            user = "root"
            password = "${var.root_user_pw}"
        }

        source = "${local.project_dir}/src/"
        destination = "/var/www/src/"
    }

    #  Provision Dockerfile
    provisioner "file" {
        connection {
            host = "${self.ip_address}"
            type = "ssh"
            user = "root"
            password = "${var.root_user_pw}"
        }

        source = "${local.project_dir}/Dockerfile"
        destination = "/var/www/Dockerfile"
    }

    #  Provision requirements.txt
    provisioner "file" {
        connection {
            host = "${self.ip_address}"
            type = "ssh"
            user = "root"
            password = "${var.root_user_pw}"
        }

        source = "${local.project_dir}/requirements.txt"
        destination = "/var/www/requirements.txt"
    }

    # Provision entrypoint.sh
    provisioner "file" {
      connection {
        host = "${self.ip_address}"
        type = "ssh"
        user = "root"
        password = "${var.root_user_pw}"
      }

      source =  "${local.project_dir}/entrypoint.sh"
      destination = "/var/www/entrypoint.sh"
    }

    # Execute docker build and run
    provisioner "remote-exec" {
      connection {
        host = "${self.ip_address}"
        type = "ssh"
        user = "root"
        password = "${var.root_user_pw}"
      }

      inline = [
        "cd /var/www/",
        "docker build -f Dockerfile -t pyapp .",
        "docker run  --restart always -p 80:8001 -e PORT=8001 -d pyapp",
      ]
    }
}
