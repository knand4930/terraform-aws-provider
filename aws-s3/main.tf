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

resource "aws_s3_bucket" "newBucket" {
  bucket = "bucket-${random_id.rand_id.hex}"
#   acl    = "private"
}

resource "aws_s3_object" "upload_bucket" {
  bucket = aws_s3_bucket.newBucket.bucket
  key    = "mydata.txt"
  source = "myfile.txt"
#   etag   = filemd5("myfile.txt")
  
}

output "name" {
  value = random_id.rand_id.hex
}