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