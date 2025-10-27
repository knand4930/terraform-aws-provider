terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}



resource "aws_s3_bucket" "main" {
  bucket = "my-bucket-787085"
}