# Create S3 bucket
resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucket_name
  website {
    # Enable website hosting on the bucket
    index_document = "index.html"
    error_document = "error.html"
  }
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
  block_public_acls       = false  # Allow public ACLs
  block_public_policy     = false  # Allow public policies
  ignore_public_acls      = false  # Don't ignore existing public ACLs
  restrict_public_buckets = false  # Allow public bucket access
}

# S3 Bucket ACL (Allowing public-read for all objects)
resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.example,
  ]
  bucket = aws_s3_bucket.mybucket.id
  acl    = "public-read"  # Public read access for the objects
}

# Upload objects to S3 (with public-read ACL)
resource "aws_s3_object" "index" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "index.html"
  source = "index.html"
  acl    = "public-read"  # Public-read ACL
  content_type = "text/html"
}

resource "aws_s3_object" "error" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "error.html"
  source = "error.html"
  acl    = "public-read"  # Public-read ACL
  content_type = "text/html"
}

resource "aws_s3_object" "style" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "style.css"
  source = "style.css"
  acl    = "public-read"  # Public-read ACL
  content_type = "text/css"
}

resource "aws_s3_object" "script" {
  bucket = aws_s3_bucket.mybucket.id
  key    = "script.js"
  source = "script.js"
  acl    = "public-read"  # Public-read ACL
  content_type = "text/javascript"
}

# Allow public read access via bucket policy
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.mybucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.mybucket.arn}/*"
        Principal = "*"
      }
    ]
  })
}
