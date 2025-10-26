terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"

}

resource "random_id" "rand_id" {
    byte_length = 8
}

resource "aws_s3_bucket" "mywebsitebucket" {
  bucket = "mywebsitebucket${random_id.rand_id.hex}"
#   acl    = "private"
}


resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mywebsitebucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.mywebsitebucket.id
  
  depends_on = [aws_s3_bucket_public_access_block.example] 
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.mywebsitebucket.arn}/*"
      },
    ]
  })
}


resource "aws_s3_bucket_website_configuration" "s3_web_configurations" {
  bucket = aws_s3_bucket.mywebsitebucket.id

  index_document {
    suffix = "index.html"
  }
}



resource "aws_s3_object" "index_html" {
  bucket       = aws_s3_bucket.mywebsitebucket.bucket
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  etag         = filemd5("index.html")  # Add this
}

resource "aws_s3_object" "styles_css" {
  bucket       = aws_s3_bucket.mywebsitebucket.bucket
  key          = "styles.css"
  source       = "styles.css"
  content_type = "text/css"
  etag         = filemd5("styles.css")  # Add this
}


output "name" {
  value = random_id.rand_id.hex
}

output "website_url" {
  value = "http://${aws_s3_bucket_website_configuration.s3_web_configurations.website_endpoint}"
}