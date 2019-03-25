resource "tls_private_key" "sharedKey" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "aws_key_pair" "generated_key" {
    key_name = "${var.key_name}"
    public_key = "${tls_private_key.sharedKey.public_key_openssh}"
}

resource "local_file" "private_key" {
  filename = "skey.pem"
  content = "${tls_private_key.sharedKey.private_key_pem}"
}

resource "aws_instance" "node01" {
  ami = "${lookup(var.amis, "ubuntu-server")}"
    instance_type = "t2.micro"
  tags = {
      "Name"="${var.instance_names[1]}"
      "training"="${var.training_name}"
  }
  key_name="${aws_key_pair.generated_key.key_name}"
  
  provisioner "remote-exec" {
    inline = [
        "sudo apt install python --yes"
        ]

    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${local_file.private_key.content}"
    }    
  }
}

resource "aws_instance" "node02" {
  ami = "${lookup(var.amis, "ubuntu-server")}"
    instance_type = "t2.micro"
  tags = {
      "Name"="${var.instance_names[2]}"
      "training"="${var.training_name}"
  }
  #depends_on = ["aws_instance.node01", "aws_instance.node02"]

  key_name="${aws_key_pair.generated_key.key_name}"
    provisioner "remote-exec" {
    inline = [
        "sudo apt install python --yes"
        ]

    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${local_file.private_key.content}"
    }    
  }
}

resource "aws_instance" "ansible-host" {
  ami = "${lookup(var.amis, "ubuntu-server")}"
  instance_type = "t2.micro"
  tags = {
      "Name"="${var.instance_names[0]}"
      "training"="${var.training_name}"
  }
  key_name="aws-hewa"

  provisioner "file" {
      source = "${local_file.private_key.filename}"
      destination = "/home/ubuntu/.ssh/${local_file.private_key.filename}"
    
        connection {
            type = "ssh"
            user = "ubuntu"
            private_key = "${file("/Users/ojitha/.aws/aws-hewa.pem")}"
        }
  }

  provisioner "remote-exec" {
    inline = [
        "sudo apt-get update --yes",
        "sudo apt-get install software-properties-common --yes",
        "sudo apt-add-repository --yes --update ppa:ansible/ansible",
        "sudo apt-get install ansible --yes",
        "chmod 400 /home/ubuntu/.ssh/${local_file.private_key.filename}",
        "echo '[demo_hosts]' | sudo tee -a /etc/ansible/hosts > /dev/null",
        "echo '${var.instance_names[1]} ansible_user=ubuntu' | sudo tee -a /etc/ansible/hosts > /dev/null",
        "echo '${var.instance_names[2]} ansible_user=ubuntu' | sudo tee -a /etc/ansible/hosts > /dev/null",
        "echo '${aws_instance.node01.private_ip} ${var.instance_names[1]}' | sudo tee -a /etc/hosts > /dev/null",
        "echo '${aws_instance.node02.private_ip} ${var.instance_names[2]}' | sudo tee -a /etc/hosts > /dev/null"
    ]

    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${file("/Users/ojitha/.aws/aws-hewa.pem")}"
    }
  }


}
