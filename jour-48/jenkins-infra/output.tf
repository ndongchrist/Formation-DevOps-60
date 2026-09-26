output "jenkins_url" {
  value = "http://${aws_instance.jenkins.public_ip}:8080"
}

output "ssh_command" {
  value = "ssh -i ma-cle.pem ubuntu@${aws_instance.jenkins.public_ip}"
}