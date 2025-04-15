terraform {
  backend "s3" {
    bucket         = "my-terraform-state-2025"
    key            = "ec2/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
  }
}

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