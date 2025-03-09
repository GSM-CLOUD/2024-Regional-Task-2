resource "aws_s3_bucket" "s3_bucket_file" {
  bucket = "${var.prefix}-file-${var.bucket_custom_prefix}"
  force_destroy = true
  tags = {
    "Name" = "${var.prefix}-file-${var.bucket_custom_prefix}"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_backend_bucket_public_access" {
  bucket                  = aws_s3_bucket.s3_bucket_file.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket" "s3_bucket_frontend" {
  bucket = "${var.prefix}-frontend-${var.bucket_custom_prefix}"
  force_destroy = true
  tags = {
    "Name" = "${var.prefix}-frontend-${var.bucket_custom_prefix}"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_frontend_bucket_public_access" {
  bucket                  = aws_s3_bucket.s3_bucket_frontend.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_object" "backend-dev" {
  bucket = aws_s3_bucket.s3_bucket_file.id
  key = "/backend/skills-backend.zip"
  source = "${path.module}/app/skills-backend.zip"
  content_type = "application/zip"
}

resource "aws_s3_object" "frontend-dev" {
  bucket = aws_s3_bucket.s3_bucket_file.id
  key = "/frontend/index.html"
  source = "${path.module}/app/index.html"
  content_type = "application/html"
}

resource "aws_s3_object" "frontend-production" {
  bucket = aws_s3_bucket.s3_bucket_frontend.id
  key = "index.html"
  source = "${path.module}/app/index.html"
  content_type = "application/html"
}