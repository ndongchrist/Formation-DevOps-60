#!/usr/bin/env bash
# Crée le bucket S3 qui stockera l'état Terraform (à exécuter UNE SEULE FOIS).
set -euo pipefail

REGION="${REGION:-eu-west-3}"
BUCKET="${1:?Usage: $0 <nom-du-bucket-unique>}"

aws s3api create-bucket --bucket "$BUCKET" --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"

aws s3api put-bucket-versioning --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled

aws s3api put-bucket-encryption --bucket "$BUCKET" \
  --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

aws s3api put-public-access-block --bucket "$BUCKET" \
  --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

echo "Bucket $BUCKET prêt. Mets ce nom dans infra/versions.tf (bloc backend)."
