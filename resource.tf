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
        "sudo apt-add-repository ppa:ansible/ansible -y",
        "sudo apt-get update",
        "sudo apt-get install ansible -y",
        "chmod 400 /home/ubuntu/.ssh/${local_file.private_key.filename}"
    ]

    connection {
        type = "ssh"
        user = "ubuntu"
        private_key = "${file("/Users/ojitha/.aws/aws-hewa.pem")}"
    }
  }


}
