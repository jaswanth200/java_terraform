terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0"
    }
  }
}

provider "aws" {
  region  = "ap-south-1"
  version = "~> 5.46.0"
}

# Creating VPC
resource "aws_vpc" "provpc" {
  cidr_block = "10.10.0.0/16"
  tags = {   
    Name = "provpc"
  }
}

# Creating Internet Gateway
resource "aws_internet_gateway" "proig" {
  vpc_id = aws_vpc.provpc.id
  tags = {
    Name = "proig"
  }
}

# Creating Subnet in Availability Zone ap-south-1a
resource "aws_subnet" "aval_1a_subnet" {
  vpc_id     = aws_vpc.provpc.id
  cidr_block = "10.10.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "aval_1a_subnet"
  }
}

# Creating Route Table for Availability Zone 1a
resource "aws_route_table" "aval_1a_rt" {
  vpc_id = aws_vpc.provpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.proig.id
  }
  tags = {
    Name = "aval_1a_rt"
  }
}

# Attaching Public Route Table to Availability Zone 1a Subnet 
resource "aws_route_table_association" "public_attach_1a" {
  subnet_id      = aws_subnet.aval_1a_subnet.id
  route_table_id = aws_route_table.aval_1a_rt.id
}

# Creating Subnet in Availability Zone ap-south-1b
resource "aws_subnet" "aval_1b_subnet" {
  vpc_id     = aws_vpc.provpc.id
  cidr_block = "10.10.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "aval_1b_subnet"
  }  
}

# Creating Route Table for Availability Zone 1b
resource "aws_route_table" "aval_1b_rt" {
  vpc_id = aws_vpc.provpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.proig.id
  }
  tags = {
    Name = "aval_1b_rt"
  }
}

# Attaching Public Route Table to Availability Zone 1b Subnet 
resource "aws_route_table_association" "public_attach_1b" {
  subnet_id      = aws_subnet.aval_1b_subnet.id
  route_table_id = aws_route_table.aval_1b_rt.id
}

# Creating Subnet in Availability Zone ap-south-1c
resource "aws_subnet" "aval_1c_subnet" {
  vpc_id     = aws_vpc.provpc.id
  cidr_block = "10.10.3.0/24"
  availability_zone = "ap-south-1c"
  tags = {
    Name = "aval_1c_subnet"
  }  
}

# Creating Route Table for Availability Zone 1c
resource "aws_route_table" "aval_1c_rt" {
  vpc_id = aws_vpc.provpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.proig.id
  }
  tags = {
    Name = "aval_1c_rt"
  }
}

# Attaching Public Route Table to Availability Zone 1c Subnet 
resource "aws_route_table_association" "public_attach_1c" {
  subnet_id      = aws_subnet.aval_1c_subnet.id
  route_table_id = aws_route_table.aval_1c_rt.id
}

# Creating Security Group for Instances
resource "aws_security_group" "prosg" {
  name        = "prosg"
  vpc_id      = aws_vpc.provpc.id
  description = "security_group"

  ingress {
    description = "http from all internet"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh from all internet"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description      = "http to all internet"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"] 
  }
}

# Creating Java Instance in Availability Zone ap-south-1a
resource "aws_instance" "java_First_Instance" {
  ami           = "ami-0e1d06225679bc1c5"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.aval_1a_subnet.id
  vpc_security_group_ids = [aws_security_group.prosg.id]  # Use security group ID instead of name
  tags = {
    Name = "javaFirstInstance"
  }
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y openjdk-11-jdk
              EOF
  key_name = "vv"  # Ensure this matches your existing key pair
  associate_public_ip_address = true
}

# Creating AMI from Java Instance
resource "aws_ami_from_instance" "java_First_Instance_ami" {
  name               = "java_First_Instance-ami"
  source_instance_id = aws_instance.java_First_Instance.id
  depends_on         = [aws_instance.java_First_Instance]
  tags = {
    Name = "java_FirstInstanceAMI"
  }
}

