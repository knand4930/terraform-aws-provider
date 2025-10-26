terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = var.region

}

resource "aws_instance" "myserver" {
  ami           = "ami-06fa3f12191aa3337"
  instance_type = var.instance_type
  tags = {
    Name = "MyFirstServer"
  }
}