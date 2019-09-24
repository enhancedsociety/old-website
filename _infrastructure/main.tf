variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "ap-southeast-2"
}

terraform {
  backend "s3" {
    bucket = "cakeequity-terraform"
    key    = "enhanced-website"
    region = "ap-southeast-2"
  }
}

locals {
  common_tags = {
    Terraform   = "true"
  }
}

provider "aws" {
  version = "~> 1.9.0"
  region = "${var.aws_region}"
}

data "aws_route53_zone" "enhancedsociety" {
  name = "enhancedsociety.com"
}


# Domain A-record for APEX

resource "aws_route53_record" "apex" {
  zone_id = "${data.aws_route53_zone.enhancedsociety.zone_id}"
  name    = "enhancedsociety.com"
  type    = "A"
  alias {
    name = "${aws_cloudfront_distribution.apex_distribution.domain_name}"
    zone_id = "${aws_cloudfront_distribution.apex_distribution.hosted_zone_id}"
    evaluate_target_health = true
  }
}


# Domain A-record for WWW origin

resource "aws_route53_record" "cname_www-orig" {
  zone_id = "${data.aws_route53_zone.enhancedsociety.zone_id}"
  name    = "www-orig"
  type    = "CNAME"
  ttl     = "300"
  records = ["enhancedsociety.github.io"]
}


# CloudFront distribution

resource "aws_cloudfront_distribution" "www_distribution" {
  origin {
    domain_name = "${aws_route53_record.cname_www-orig.name}.enhancedsociety.com"
    origin_id = "ID-${aws_route53_record.cname_www-orig.name}.enhancedsociety.com"
    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port = "80"
      https_port = "443"
      origin_ssl_protocols = [
        "TLSv1"]
    }

  }
  aliases = ["www.enhancedsociety.com"]
  enabled = true
  tags = "${local.common_tags}"

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
      "PUT",
      "POST",
      "PATCH",
      "DELETE"]
    cached_methods = [
      "GET",
      "HEAD"]
    target_origin_id = "ID-${aws_route53_record.cname_www-orig.name}.enhancedsociety.com"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 3600 # increase this after testing
    compress               = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = "${var.cloudfront_certificate_arn}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}


# Domain CNAME for WWW

resource "aws_route53_record" "cname_www" {
  zone_id = "${data.aws_route53_zone.enhancedsociety.zone_id}"
  name = "www"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_cloudfront_distribution.www_distribution.domain_name}"]
}


# S3 bucket for apex/root domain redirect

resource "aws_s3_bucket" "s3_enhancedsociety_com" {
  bucket = "enhancedsociety.com"
  acl    = "public-read"
  website {
    redirect_all_requests_to = "https://www.enhancedsociety.com"
  }
}


# CloudFront distribution for apex/root domain

resource "aws_cloudfront_distribution" "apex_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.s3_enhancedsociety_com.id}.${aws_s3_bucket.s3_enhancedsociety_com.website_domain}"
    origin_id = "ID-${aws_s3_bucket.s3_enhancedsociety_com.id}.${aws_s3_bucket.s3_enhancedsociety_com.website_domain}"
    custom_origin_config {
      origin_protocol_policy = "http-only"
      http_port = "80"
      https_port = "443"
      origin_ssl_protocols = [
        "TLSv1"]
    }

  }
  aliases = ["enhancedsociety.com"]
  enabled = true
  tags = "${local.common_tags}"

  default_cache_behavior {
    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
      "PUT",
      "POST",
      "PATCH",
      "DELETE"]
    cached_methods = [
      "GET",
      "HEAD"]
    target_origin_id = "ID-${aws_s3_bucket.s3_enhancedsociety_com.id}.${aws_s3_bucket.s3_enhancedsociety_com.website_domain}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 3600 # increase this after testing
    compress               = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }
  viewer_certificate {
    acm_certificate_arn = "${var.cloudfront_certificate_arn}"
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.1_2016"
  }
}
