#!/bin/bash

# Définition des variables
LOG_FILE="/var/log/aws_monitoring.log"
EMAIL_RECIPIENTS="christianhonore2003@gmail.com"

# Fonction pour récupérer les instances EC2 en cours d’exécution
list_running_instances() {
    echo "=== Liste des instances EC2 en cours d’exécution ===" >> "$LOG_FILE"
    aws ec2 describe-instances --filters "Name=instance-state-name,Values=running" \
        --query 'Reservations[*].Instances[*].[InstanceId,PublicIpAddress]' \
        --output text >> "$LOG_FILE"
}

# Fonction pour lister tous les détails des instances EC2
list_all_instances() {
    echo "=== Liste complète des instances EC2 ===" >> "$LOG_FILE"
    aws ec2 describe-instances >> "$LOG_FILE"
}

# Fonction pour lister les buckets S3
list_s3_buckets() {
    echo "=== Liste des buckets S3 ===" >> "$LOG_FILE"
    aws s3 ls >> "$LOG_FILE"
}

# Fonction pour lister les utilisateurs IAM
list_iam_users() {
    echo "=== Liste des utilisateurs IAM ===" >> "$LOG_FILE"
    aws iam list-users >> "$LOG_FILE"
}

# Fonction pour envoyer un email avec les logs
send_email_report() {
    SUBJECT="Rapport de Monitoring AWS"
    BODY="Veuillez trouver ci-joint le rapport du monitoring AWS."
    mail -s "$SUBJECT" "$EMAIL_RECIPIENTS" < "$LOG_FILE"
}

# Exécution des fonctions
echo "=== Début du monitoring AWS : $(date) ===" > "$LOG_FILE"
list_running_instances
list_all_instances
list_s3_buckets
list_iam_users
send_email_report
echo "=== Fin du monitoring AWS : $(date) ===" >> "$LOG_FILE"
