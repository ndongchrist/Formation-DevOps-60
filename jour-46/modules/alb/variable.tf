variable "load_balancer_name" {
  type        = string
  description = "value"
  default     = "web-app-lb"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC the target group and instances live in"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs the load balancer should be attached to"
}

variable "security_group_id" {
  type        = string
  description = "ID of the security group to attach to the load balancer"
}

variable "instance_1_id" {
  type        = string
  description = "ID of the first instance to attach to the target group"
}

variable "instance_2_id" {
  type        = string
  description = "ID of the second instance to attach to the target group"
}