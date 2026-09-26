output "instance_1_public_ip" {
  value = aws_instance.instance_1.public_ip
}

output "instance_2_public_ip" {
  value = aws_instance.instance_2.public_ip
}

output "instance_1_id" {
  value = aws_instance.instance_1.id
}

output "instance_2_id" {
  value = aws_instance.instance_2.id
}