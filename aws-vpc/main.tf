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


#create a vpc

resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  tags = {
    Name = "my_vpc"
  }
  
}

#create a private subnet
resource "aws_subnet" "private-subnet" {
  cidr_block = "10.0.1.0/24"
  vpc_id     = aws_vpc.my_vpc.id
  tags = {
    Name = "my_private_subnet"
  }
}

#create an public subnet
resource "aws_subnet" "public-subnet" {
  cidr_block = "10.0.2.0/24"
  vpc_id     = aws_vpc.my_vpc.id
  tags = {
    Name = "my_public_subnet"
  }
}


# create an internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_igw"
  }
}

# create a route table
resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
  tags = {
    Name = "my_route_table"
  }
}

# associate the route table with the public subnet
resource "aws_route_table_association" "public_sub" {
    route_table_id = aws_route_table.my_route_table.id
    subnet_id      = aws_subnet.public-subnet.id
}


resource "aws_instance" "myserver" {
  ami           = "ami-06fa3f12191aa3337"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public-subnet.id
  tags = {
    Name = "MyFirstServer"
  }
}