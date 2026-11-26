data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)  # slice(list, start, end) -> 0,1
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = local.azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]     # les nœuds Kubernetes
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"] # les load balancers publics

  enable_nat_gateway = true
  single_nat_gateway = true # une seule NAT = moins cher (OK pour une démo, pas pour la prod)

  # Ces tags indiquent à Kubernetes où créer les load balancers
  public_subnet_tags  = { "kubernetes.io/role/elb" = 1 }
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = 1 }
}
