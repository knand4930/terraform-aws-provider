terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
    }
  }
}

# provider "aws" {
#   # Configuration options
#   region = "ap-south-1"

# }

provider "aws" {
  # Configuration options
  region = "us-east-1"

}


# security groups data source
data "aws_security_groups" "name" {
  tags = {
    mywebserver = "http"
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

# AWS Available Zones data source
data "aws_availability_zones" "available" {
  state = "available"
}

output "aws_zones" {
  value = data.aws_availability_zones.available
}


# Get Account Id Details  
data "aws_caller_identity" "current" {
}

output "caller_info" {
  value = data.aws_caller_identity.current.account_id
}


# Get AWS Region Details
data "aws_region" "current" {
}
output "region_info" {
  value = data.aws_region.current.region
}
# data "aws_ami" "name" {
#   # executable_users = ["self"]
#   most_recent = true
#   # name_regex       = "^myami-[0-9]{3}"
#   owners = ["amazon"]
# }

# output "aws_ami" {
#   value = data.aws_ami.name.id

# }


# resource "aws_instance" "myserver" {
#   # ami           = "ami-06fa3f12191aa3337"
#   ami           = data.aws_ami.name.id
#   instance_type = "t2.micro"
#   tags = {
#     Name = "MyFirstServer"
#   }
# }
