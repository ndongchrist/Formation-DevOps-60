variable "instance_type" {
  type        = string
  description = "value"
}

variable "bucket_name" {
  type        = string
  description = "value"
  default     = "devops-goldenbrain-web-app-data"
}

variable "security_group_type" {
  type        = string
  description = "value"
  default     = "ingress"
}

variable "load_balancer_security_group" {
  type        = string
  default     = "alb-security-group"
  description = "value"
}


variable "load_balancer_name" {
  type        = string
  description = "value"
  default     = "web-app-lb"
}


variable "domain_name" {
  type        = string
  description = "value"
  default     = "your-domain-name.com"
}

variable "db_name" {
  type        = string
  default     = "my_db"
  description = "value"
}