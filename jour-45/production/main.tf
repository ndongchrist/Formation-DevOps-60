terraform {
  # Assumes s3 bucket and dynamo DB table already set up
  # See /code/03-basics/aws-backend
  backend "s3" {
    bucket         = "devops-goldenbrain-tf-state"
    key            = "jour-44/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-locking"
    use_lockfile   = false
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# aws instances
module "instances" {
  source = "../modules/ec2"

  instance_type       = var.instance_type
  security_group_name = module.instance_security.instances_security_group_name
}

# s3 bucket for data
module "aws_s3" {
  source = "../modules/s3"

  bucket_name = var.bucket_name
}

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_subnet_ids" "default_subnet" {
  vpc_id = data.aws_vpc.default_vpc.id
}

#Security Groups
module "instance_security" {
  source = "../modules/security"

  security_group_type          = var.security_group_type
  load_balancer_security_group = var.load_balancer_security_group
}

# Amazon Elastic Laod Balancer
module "alb" {
  source = "../modules/alb"

  load_balancer_name = var.load_balancer_name
  vpc_id             = data.aws_vpc.default_vpc.id
  subnet_ids         = data.aws_subnet_ids.default_subnet.ids
  security_group_id  = module.instance_security.alb_security_group_id
  instance_1_id      = module.instances.instance_1_id
  instance_2_id      = module.instances.instance_2_id
}

module "dns" {
  source = "../modules/dns"

  domain_name            = var.domain_name
  load_balancer_dns_name = module.alb.alb_dns_name
  load_balancer_zone_id  = module.alb.alb_zone_id
}


module "db" {
  source = "../modules/db"

  db_name = var.db_name
}