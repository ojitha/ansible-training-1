provider "aws" {
  region = "${var.my_region}"
}

terraform {
    required_version =  ">= 0.11.13"
    backend "s3" {
        bucket = "ojitha"
        key = "test/ansible_training"
        region = "ap-southeast-2"
        encrypt = "true"
    }
}