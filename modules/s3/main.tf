terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.64.0"
    }
  }
}

# -------------------
# Buckets for lambdas
# -------------------

resource "aws_s3_bucket" "lambdas" {
  bucket  = local.s3_config.bucket_name_lambdas[var.region]
}

resource "aws_s3_bucket_public_access_block" "lambdas" {
  bucket                  = local.s3_config.bucket_name_lambdas[var.region]
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# --------------------------------------
# Buckets for posts with replication rule
# ---------------------------------------


resource "aws_s3_bucket" "posts" {
  bucket  = local.s3_config.bucket_name_posts[var.region]
}

resource "aws_s3_bucket_public_access_block" "posts" {
  bucket                  = local.s3_config.bucket_name_posts[var.region]
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "posts" {
  bucket = local.s3_config.bucket_name_posts[var.region]

  versioning_configuration {
    status = "Enabled"
  }
}

# README antipode-lambda: priority?? what and where is this
resource "aws_s3_bucket_replication_configuration" "writer_to_reader" {
  count       = var.replication_rule ? 1 : 0

  # must have bucket versioning enabled first
  depends_on  = [aws_s3_bucket_versioning.posts]

  role        = local.s3_config.s3_role_arn
  bucket      = local.s3_config.bucket_name_posts[var.region]

  rule {
    id     = "to-reader-${var.secondary_region}"
    status = "Enabled"

    destination {
      bucket        = "arn:aws:s3:::${local.s3_config.bucket_name_posts[var.secondary_region]}"
    }
  }
}

# ------------------------------------------------------
# Bucket lifecycle configuration for rendezvous metadata
# ------------------------------------------------------

resource "aws_s3_bucket_lifecycle_configuration" "posts_rendezvous" {
  bucket = local.s3_config.bucket_name_posts[var.region]

  rule {
    id = "rendezvous-expiration"
    status = "Enabled"

    filter {
      prefix = "rendezvous/"
    }

    expiration {
      days = 1
    }

    noncurrent_version_expiration {
      noncurrent_days = 1
    }
  }
}