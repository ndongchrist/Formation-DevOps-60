#!/bin/bash
set -e

# ==========================================
# System packages
# ==========================================

apt-get update -y

apt-get install -y \
  fontconfig \
  openjdk-21-jre \
  unzip \
  curl \
  gnupg \
  git \
  lsb-release \
  ca-certificates

# ==========================================
# Jenkins
# ==========================================

echo "Installing Jenkins..."

mkdir -p /etc/apt/keyrings

# Jenkins current signing key
curl -fsSL \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
  -o /etc/apt/keyrings/jenkins-keyring.asc

# Jenkins LTS repository
cat > /etc/apt/sources.list.d/jenkins.list <<EOF
deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/
EOF

apt-get update -y

apt-get install -y jenkins

systemctl enable jenkins
systemctl start jenkins

# ==========================================
# Node.js 22
# ==========================================

echo "Installing Node.js 22..."

curl -fsSL https://deb.nodesource.com/setup_22.x | bash -

apt-get install -y nodejs

# ==========================================
# Terraform
# ==========================================

echo "Installing Terraform..."

mkdir -p /etc/apt/keyrings

curl -fsSL https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor -o /etc/apt/keyrings/hashicorp.gpg

cat > /etc/apt/sources.list.d/hashicorp.list <<EOF
deb [signed-by=/etc/apt/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main
EOF

apt-get update -y

apt-get install -y terraform

# ==========================================
# AWS CLI v2
# ==========================================

echo "Installing AWS CLI v2..."

curl -fsSL \
  "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" \
  -o /tmp/awscliv2.zip

rm -rf /tmp/aws

unzip -q /tmp/awscliv2.zip -d /tmp

/tmp/aws/install

rm -rf /tmp/aws /tmp/awscliv2.zip

# ==========================================
# Verification
# ==========================================

echo "=========================================="
echo "Installation completed"
echo "=========================================="

echo "Java:"
java -version

echo "Jenkins:"
systemctl --no-pager status jenkins || true

echo "Node:"
node --version

echo "NPM:"
npm --version

echo "Terraform:"
terraform version

echo "AWS CLI:"
aws --version

echo "=========================================="
echo "Jenkins initial password:"
echo "=========================================="

if [ -f /var/lib/jenkins/secrets/initialAdminPassword ]; then
    cat /var/lib/jenkins/secrets/initialAdminPassword
fi

echo "=========================================="