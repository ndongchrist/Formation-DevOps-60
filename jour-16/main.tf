provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "my_ec2" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 (vérifiez l'AMI pour votre région)
  instance_type = "t2.micro"
  tags = {
    Name = "Terraform-EC2"
  }
}