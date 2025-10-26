terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
  }
  backend "s3" {
    bucket = "bucket-2eba136499f64be0"
    key    = "backend.tfstate"
    region = "ap-south-1"
    
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"

}

resource "aws_instance" "myserver" {
  ami           = "ami-06fa3f12191aa3337"
  instance_type = "t3.micro"
  tags = {
    Name = "MyFirstServer"
  }
}