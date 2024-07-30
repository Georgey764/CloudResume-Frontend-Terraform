terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "us-east-1"
}

# S3 Bucket Policies Below Here

resource "aws_s3_bucket" "s3_cloud_resume" {
  bucket = "george-cloud-resume"

  tags = {
    Name        = "Cloud Resume Bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_ownership_controls" "s3_ownership" {
  bucket = aws_s3_bucket.s3_cloud_resume.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

data "aws_iam_policy_document" "s3_allow_policy" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject",
    ]

    resources = [
      aws_s3_bucket.s3_cloud_resume.arn,
      "${aws_s3_bucket.s3_cloud_resume.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_policy" "s3_policy_attach" {
  depends_on = [
    aws_s3_bucket.s3_cloud_resume,
    aws_s3_bucket_ownership_controls.s3_ownership
  ]
  bucket = aws_s3_bucket.s3_cloud_resume.id
  policy = data.aws_iam_policy_document.s3_allow_policy.json
}

resource "aws_s3_bucket_website_configuration" "webconfig_cloud_resume" {
  bucket = aws_s3_bucket.s3_cloud_resume.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_public_access" {
  bucket = aws_s3_bucket.s3_cloud_resume.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "bucket_public_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.s3_ownership,
    aws_s3_bucket_public_access_block.s3_public_access,
  ]

  bucket = aws_s3_bucket.s3_cloud_resume.id
  acl    = "public-read"
}

variable "objects_to_upload" {
  type = map
  default = {
    "index.html" = {
      "path" = "./assets/index.html"
      "content_type" = "text/html"
    }
    "error.html" = {
      "path" = "./assets/error.html"
      "content_type" = "text/html"
    }
    "script.js" = {
      "path" = "./assets/script.js",
      "content_type" = "text/javascript"
    }
  }
}

resource "aws_s3_object" "object" {
  for_each = var.objects_to_upload
  depends_on = [
    aws_s3_bucket.s3_cloud_resume
  ]

  bucket = "george-cloud-resume"
  key    = each.key
  source = each.value["path"]
  content_type = each.value["content_type"]
}
