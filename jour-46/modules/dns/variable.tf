variable "domain_name" {
  type        = string
  description = "value"
  default     = "your-domain-name.com"
}

variable "load_balancer_dns_name" {
  type        = string
  description = "DNS name of the load balancer to alias to"
}

variable "load_balancer_zone_id" {
  type        = string
  description = "Hosted zone ID of the load balancer to alias to"
}