# Stockage : un bucket S3 privé, avec versionnement et chiffrement côté
# serveur. L'accès public est bloqué à tous les niveaux : ce bucket sert
# aux fichiers de l'application, jamais à un site public.

resource "aws_s3_bucket" "principal" {
  bucket = "${var.nom_projet}-${var.environnement}-fichiers"

  tags = {
    Name = "${var.nom_projet}-${var.environnement}-fichiers"
  }
}

resource "aws_s3_bucket_versioning" "principal" {
  bucket = aws_s3_bucket.principal.id

  versioning_configuration {
    status = var.versionnement ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "principal" {
  bucket = aws_s3_bucket.principal.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "principal" {
  bucket = aws_s3_bucket.principal.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
