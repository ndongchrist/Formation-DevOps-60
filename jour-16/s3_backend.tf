# Configure AWS pour utiliser la région us-east-1 (changez si vous êtes dans une autre région)
provider "aws" {
  region = "us-east-1"
}

# Crée un bucket S3 pour sauvegarder le fichier state de Terraform
resource "aws_s3_bucket" "terraform_state" {
  bucket = "my-terraform-state-2025" # Donnez un nom unique (par exemple, ajoutez votre nom ou un numéro)

  # Active le versionnement pour garder un historique du state
  versioning {
    enabled = true
  }
}

# Crée une table DynamoDB pour éviter que plusieurs personnes modifient le state en même temps
resource "aws_dynamodb_table" "terraform_locks" {
  name         = "terraform-locks"
  billing_mode = "PAY_PER_REQUEST" # Pas de frais fixes, payez seulement ce que vous utilisez
  hash_key     = "LockID"

  # Définit la clé utilisée par la table
  attribute {
    name = "LockID"
    type = "S" # S signifie "string" (chaîne de caractères)
  }
}

# Configure Terraform pour sauvegarder le state dans le bucket S3
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-2025" # Doit être le même nom que le bucket
    key            = "terraform.tfstate"       # Nom du fichier state
    region         = "us-east-1"               # Même région que le provider
    dynamodb_table = "terraform-locks"         # Nom de la table DynamoDB
  }
}