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
  region = "us-east-1"

}

# security groups data source
data "aws_security_groups" "name" {
  tags = {
    ENV = "production"
  }
}

output "aws_security_groups" {
  value = data.aws_security_groups.name
}

# VPC id data source
data "aws_vpcs" "name" {
  tags = {
    ENV = "PROD"
  }
}

output "aws_vpcs" {
  value = data.aws_vpcs.name

}

#aws subnet data source
data "aws_subnets" "name" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpcs.name.ids[0]]

  }
    filter {
    name   = "tag:Name"
    values = ["private-subnet"]
  }
}

resource "aws_instance" "myserver" {
  ami           = "ami-0360c520857e3138f"
  instance_type = "t2.micro"
  subnet_id     = data.aws_subnets.name.ids[0]
  vpc_security_group_ids = data.aws_security_groups.name.ids

  tags = {
    Name = "MyFirstServer"
  }
}
