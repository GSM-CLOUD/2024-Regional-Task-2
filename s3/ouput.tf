output "file_bucket_name" {
  value = aws_s3_bucket.s3_bucket_file.bucket
}

output "bucket_dns_name" {
  value = aws_s3_bucket.s3_bucket_frontend.bucket_regional_domain_name
}

output "bucket_name" {
  value = aws_s3_bucket.s3_bucket_frontend.bucket
}