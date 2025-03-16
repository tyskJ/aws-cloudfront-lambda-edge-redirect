# ╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗
# ║ CloudFront Lambda@Edge redirect Stack - Terraform main.tf resource                                                                               ║
# ╠════════════════════════════════════╤═════════════════════════════════════════════════════╤═══════════════════════════════════════════════════════╣
# ║ bucket                             │ aws_s3_bucket                                       │ S3 Bucket.                                            ║
# ║ bucket_encrypt                     │ aws_s3_bucket_server_side_encryption_configuration  │ S3 Bucket Encryption configuration.                   ║
# ║ bucket_block_public_access         │ aws_s3_bucket_public_access_block                   │ S3 Bucket Block Public Access.                        ║
# ║ object1                            │ aws_s3_object                                       │ Upload file.                                          ║
# ║ object2                            │ aws_s3_object                                       │ Upload file.                                          ║
# ║ oac                                │ aws_cloudfront_origin_access_control                │ CloudFront OAC.                                       ║
# ║ distribution                       │ aws_cloudfront_distribution                         │ CloudFront Distribution.                              ║
# ║ cloudfront_recordset               │ aws_route53_record                                  │ CloudFront Alias Record Set.                          ║
# ║ bucket_policy                      │ aws_s3_bucket_policy                                │ S3 Bucket Policy.                                     ║
# ╚════════════════════════════════════╧═════════════════════════════════════════════════════╧═══════════════════════════════════════════════════════╝

resource "aws_s3_bucket" "bucket" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encrypt" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    bucket_key_enabled = true
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_block_public_access" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "object1" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "index.html"
  source = "${path.module}/html/index.html"
}

resource "aws_s3_object" "object2" {
  bucket = aws_s3_bucket.bucket.bucket
  key    = "error.html"
  source = "${path.module}/html/error.html"
}

resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "cf-oac-for-s3"
  description                       = "CloudFront OAC for S3"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "distribution" {
  enabled             = true
  wait_for_deployment = true
  default_root_object = "index.html"
  origin {
    origin_id                = aws_s3_bucket.bucket.id
    domain_name              = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id
  }
  default_cache_behavior {
    target_origin_id       = aws_s3_bucket.bucket.id
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }
  custom_error_response {
    error_caching_min_ttl = 10
    error_code            = 404
    response_code         = 200
    response_page_path    = "/error.html"
  }
  aliases = [var.cloudfront_fqdn]
  viewer_certificate {
    cloudfront_default_certificate = false
    acm_certificate_arn            = var.cloudfront_cert_arn
    ssl_support_method             = "sni-only"
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
}

resource "aws_route53_record" "cloudfront_recordset" {
  zone_id = var.cloudfront_hostzone_id
  name    = var.cloudfront_fqdn
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.distribution.domain_name
    zone_id                = aws_cloudfront_distribution.distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.bucket.id
  policy = templatefile("${path.module}/json/bucket-policy.json",
    {
      BucketArn       = aws_s3_bucket.bucket.arn,
      DistributionArn = aws_cloudfront_distribution.distribution.arn
    }
  )
}
