resource "aws_ecr_repository" "django" {
  name         = "django-app"
  force_delete = true # permet à terraform destroy de supprimer le dépôt même s'il contient des images

  image_scanning_configuration {
    scan_on_push = true # scan de vulnérabilités à chaque push (rappel de la vidéo Trivy)
  }
}
