provider "aws" {
  region = var.region
}

resource "aws_instance" "my_ec2" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = "Terraform-EC2"
  }
}