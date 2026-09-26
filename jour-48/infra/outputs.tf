output "bucket_name"     { value = aws_s3_bucket.site.bucket }
# output "distribution_id" { value = aws_cloudfront_distribution.cdn.id }
output "site_url"    { value = "http://${aws_s3_bucket_website_configuration.site.website_endpoint}" }