output "nom_bucket" {
  description = "Nom du bucket S3."
  value       = aws_s3_bucket.principal.id
}

output "arn_bucket" {
  description = "ARN du bucket S3."
  value       = aws_s3_bucket.principal.arn
}
