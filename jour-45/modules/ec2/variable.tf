variable "instance_type" {
  type        = string
  description = "instance type like t3 or t2 micro"
  default     = "t2.micro"
}

variable "security_group_name" {
  type        = string
  description = "Name of the security group to attach to the instances"
}

