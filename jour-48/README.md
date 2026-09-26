aws ec2 create-key-pair \
  --key-name jenkins-key \
  --region eu-west-3 \
  --query 'KeyMaterial' \
  --output text > jenkins-key.pem

chmod 400 jenkins-key.pem



cd jenkins-infra
terraform init
terraform validate
terraform plan
terraform apply -var="key_name=jenkins-key"


cat /var/lib/jenkins/secrets/initialAdminPassword