variable "region" {
  description = "Région AWS"
  type        = string
  default     = "eu-west-3" # Paris
}

variable "cluster_name" {
  description = "Nom du cluster EKS"
  type        = string
  default     = "devops60-eks"
}

# Vérifie les versions supportées avant de tourner :
# aws eks describe-cluster-versions --query "clusterVersions[].[clusterVersion,status]" --output table
# Choisis une version en "STANDARD_SUPPORT" (l'extended support coûte plus cher).
variable "kubernetes_version" {
  description = "Version de Kubernetes"
  type        = string
  default     = "1.34"
}

variable "node_instance_type" {
  description = "Type d'instance des nœuds"
  type        = string
  default     = "t3.micro"
}

variable "node_desired_size" {
  description = "Nombre de nœuds souhaité"
  type        = number
  default     = 2
}
