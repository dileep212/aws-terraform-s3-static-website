output "aws_s3_bucket" {
  value = aws_s3_bucket.website_bucket.id
}

output "cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.cloudfront_distribution.id
}
output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.cloudfront_distribution.domain_name
}

