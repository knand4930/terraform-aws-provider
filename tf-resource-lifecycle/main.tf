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

resource "aws_security_group" "main" {
  name = "my-sg"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my-sg"
  }
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name="my-vpc"
  }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
}


resource "aws_instance" "main" {
  ami           = "ami-02d26659fd82cf299"
  instance_type = "t2.micro"
  #   instance_type          = "t2.nano"

  # vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id = aws_subnet.private.id
  associate_public_ip_address = false
  depends_on = [aws_security_group.main]

  lifecycle {
    precondition {
      condition     = aws_security_group.main.id !=""
      error_message = "Security Group ID must not be blank !!"
    }

    postcondition {
      condition     = self.public_ip != ""
      error_message = "Public IP is not present !!"
    }

    # create_before_destroy = true
    # prevent_destroy = true
    # replace_triggered_by = [ aws_security_group.main, aws_security_group.main.ingress ]
  }

  tags = {
    Name = "my-instance"
  }



  # precondition {
  #   condition     = ""
  #   error_message = "Message if condition fails"
  # }

  # postcondition {
  #   condition     = ""
  #   error_message = "Message if condition fails"
  # }

}
