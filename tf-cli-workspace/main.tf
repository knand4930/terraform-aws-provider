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
  bucket = "bucket-${terraform.workspace}-${random_id.rand_id.hex}"
#   acl    = "private"
}
