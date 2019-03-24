variable "key_name" {
    type = "string"
    default = "skey"
}

variable "instance_names" {
  type = "list"
  description = "tags for the instances 0,1,2"
}

variable "amis" {
  type = "map"
  description = "all the instances are from this ami"
}

variable "my_region" {
  type = "string"
  description = "always my region is this"
}

variable "training_name" {
    type="string"
}

output "ansible_public_ip" {
  value = "${aws_instance.ansible-host.public_dns}"
}

output "nodes_key" {
  value = "${local_file.private_key.filename}"
}






