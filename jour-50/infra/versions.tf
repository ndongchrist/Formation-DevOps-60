terraform {
  required_version = ">= 1.10"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  # Le backend ne peut pas utiliser de variables : valeurs écrites en dur.
  # Remplace le nom du bucket par celui créé avec scripts/bootstrap-backend.sh
  backend "s3" {
    bucket       = "devops-goldenbrain-tf-state"
    key          = "eks/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true # verrouillage directement dans S3, plus besoin de DynamoDB
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project   = "devops-60-jours"
      ManagedBy = "terraform"
    }
  }
}
