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

locals {
  owner = "DevOpsTeam"
}


resource "aws_instance" "myserver" {
  ami           = "ami-06fa3f12191aa3337"
  instance_type = var.instance_type

  root_block_device {
    delete_on_termination = var.root_block_config.delete_on_termination
    volume_size           = var.root_block_config.volume_size
    volume_type           = var.root_block_config.volume_type
  }

  #   tags = var.additional_tags
  tags = merge(
    {
      Name = local.owner
    },
    var.additional_tags
  )
}
