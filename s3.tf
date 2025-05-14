variable "bucketname" {
  description = "Name of the S3 bucket"
  type        = string
}

# Create S3 bucket
resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucketname

  tags = {
    Name        = var.bucketname
    Environment = "Production"
  }
}

# Ensure ownership is set correctly
resource "aws_s3_bucket_ownership_controls" "ownership" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Secure bucket public access settings
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.mybucket.id

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = false  # Required to allow static website hosting via policy
  restrict_public_buckets = false # Must be false if policy allows public
}

# Host static website content
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Upload website files with correct MIME types
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.mybucket.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  acl          = "private"
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.mybucket.id
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"
  acl          = "private"
}

resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.mybucket.id
  key          = "style.css"
  source       = "style.css"
  content_type = "text/css"
  acl          = "private"
}

resource "aws_s3_object" "script" {
  bucket       = aws_s3_bucket.mybucket.id
  key          = "script.js"
  source       = "script.js"
  content_type = "application/javascript"
  acl          = "private"
}

# Public read access policy (secured with optional condition)
resource "aws_s3_bucket_policy" "allow_public_read" {
  bucket = aws_s3_bucket.mybucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource  = "${aws_s3_bucket.mybucket.arn}/*",
        Condition = {
          StringLike = {
            "aws:Referer" = "https://example.com/*"  # Optional: tighten public access
          }
        }
      }
    ]
  })
}
