terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.64.0"
    }
  }
}

# --------------
# Main Resources
# --------------

data "aws_region" "current" {
  provider = aws
}

resource "aws_s3_bucket" "lambdas" {
  bucket  = local.buckets_lambdas[data.aws_region.current.name]
}

resource "aws_s3_bucket_public_access_block" "lambdas" {
  bucket                  = local.buckets_lambdas[data.aws_region.current.name]
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket" "posts" {
  bucket  = local.buckets_posts[data.aws_region.current.name]
}

resource "aws_s3_bucket_public_access_block" "posts" {
  bucket                  = local.buckets_posts[data.aws_region.current.name]
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "posts" {
  bucket = local.buckets_posts[data.aws_region.current.name]

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "posts_rendezvous" {
  bucket = local.buckets_posts[data.aws_region.current.name]

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

# priority??
resource "aws_s3_bucket_replication_configuration" "writer_to_reader" {
  count       = var.create_s3_replication ? 1 : 0

  # must have bucket versioning enabled first
  depends_on  = [aws_s3_bucket_versioning.posts]

  role        = local.s3_role_arn
  bucket      = local.buckets_posts[var.writer_region]

  rule {
    id     = "to-reader-${var.reader_region}"
    status = "Enabled"

    destination {
      bucket        = "arn:aws:s3:::${local.buckets_posts[var.reader_region]}"
    }
  }

}