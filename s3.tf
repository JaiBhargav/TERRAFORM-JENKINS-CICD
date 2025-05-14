# Create S3 bucket
resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucket_name
}

# S3 Bucket Ownership Controls
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.mybucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Public access block configuration (blocking public ACLs and policies)
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mybucket.id
  block_public_acls       = true   # Block public ACLs
  block_public_policy     = true   # Block public policies
  ignore_public_acls      = true   # Ignore existing public ACLs
  restrict_public_buckets = true   # Restrict public bucket access
}

# S3 Bucket ACL (Not necessary since public access is handled via the block)
resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]
  bucket = aws_s3_bucket.mybucket.id
  acl    = "private"   # Keeping this private, ACLs not needed for public access
}

# Upload objects to S3 (no acl set here)
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "index.html"
  source = "index.html"
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "error.html"
  source = "error.html"
  content_type = "text/html"
}

resource "aws_s3_object" "style" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "style.css"
  source = "style.css"
  content_type = "text/css"
}

resource "aws_s3_object" "script" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "script.js"
  source = "script.js"
  content_type = "text/javascript"
}

# S3 Bucket Website Configuration
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.id
  index_document {
    suffix = "index.html"
  }
  error_document {
    key = "error.html"
  }
}
