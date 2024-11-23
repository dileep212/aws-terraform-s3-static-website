# Create S3 bucket to hold the website
resource "aws_s3_bucket" "website_bucket" {
  bucket = var.dileepbucket
}

# Upload index.html to S3 bucket
resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.website_bucket.id
  key          = "news-grid/index.html"
  source       = "./index.html" # Path to the local index.html file
  etag         = filemd5("./index.html")
  content_type = "text/html" # Setting the MIME type
}

# Create CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "origin_access_identity" {
  comment = "Origin Access Identity for static website"
}

# Create CloudFront Distribution
resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = aws_s3_bucket.website_bucket.bucket_regional_domain_name
    origin_id   = var.dileepbucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.origin_access_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = var.website_index_document

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.dileepbucket

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "CloudFront Distribution"
    Environment = "Production"
  }
}

# S3 Bucket Policy to allow CloudFront Origin Access Identity to read objects
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = ["s3:GetObject", "s3:PutObject"]
        Effect    = "Allow"
        Resource  = "${aws_s3_bucket.website_bucket.arn}/*"
        Principal = "*"
      }
    ]
  })
}
