output "instances_security_group_name" {
  value = aws_security_group.instances.name
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}
