output "cluster_name" {
  value = module.eks.cluster_name
}

output "ecr_url" {
  value = aws_ecr_repository.django.repository_url
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "kubeconfig_cmd" {
  description = "Commande pour connecter kubectl au cluster"
  value       = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}
