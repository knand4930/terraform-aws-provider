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
  region = "ap-south-1"

}


locals {
  project = "project-01"
}


resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "${local.project}-vpc"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  count      = 2
  cidr_block = "10.0.${count.index}.0/24"
  tags = {
    Name = "${local.project}-subnet-${count.index}"
  }
}


#creating 4 ec2 instances
# resource "aws_instance" "instance" {
#   # count         = 2
#   count = length(var.ec2_config)
#   ami           = var.ec2_config[count.index].ami
#   instance_type = var.ec2_config[count.index].instance_type
#   tags = {
#     Name = "${local.project}-instance-${count.index}"
#   }
#   subnet_id = element(aws_subnet.main_subnet[*].id, count.index % length(aws_subnet.main_subnet))
#   #   subnet_id     = aws_subnet.main_subnet[count.index % length(aws_subnet.main_subnet)].id
# }



resource "aws_instance" "instance" {
  for_each = var.ec2_map
  #We will et each.key and each.value

  ami           = each.value.ami
  instance_type = each.value.instance_type

  tags = {
    Name = "${local.project}-instance-${each.key}"
  }
  subnet_id = element(aws_subnet.main_subnet[*].id, index(keys(var.ec2_map), each.key) % length(aws_subnet.main_subnet))
}


#create extension


output "aws_subnet_ids" {
  value = aws_subnet.main_subnet[*].id

  description = "The IDs of the created subnets"
}


output "aws_instance_ids_map" {
  value       = { for k, inst in aws_instance.instance : k => inst.id }
  description = "Map of instance keys to their IDs"
}

