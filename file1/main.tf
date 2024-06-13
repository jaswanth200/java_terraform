terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.53.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
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
  vpc_id            = aws_vpc.provpc.id
  cidr_block        = "10.10.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "aval_1a_subnet"
  }
}

# Creating Subnet in Availability Zone ap-south-1b
resource "aws_subnet" "aval_1b_subnet" {
  vpc_id            = aws_vpc.provpc.id
  cidr_block        = "10.10.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "aval_1b_subnet"
  }
}

# Creating Subnet in Availability Zone ap-south-1c
resource "aws_subnet" "aval_1c_subnet" {
  vpc_id            = aws_vpc.provpc.id
  cidr_block        = "10.10.3.0/24"
  availability_zone = "ap-south-1c"
  tags = {
    Name = "aval_1c_subnet"
  }
}

# Creating Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.provpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.proig.id
  }

  tags = {
    Name = "public_rt"
  }
}

# Attaching Route Table to Subnets
resource "aws_route_table_association" "public_attach_1a" {
  subnet_id      = aws_subnet.aval_1a_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_attach_1b" {
  subnet_id      = aws_subnet.aval_1b_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_attach_1c" {
  subnet_id      = aws_subnet.aval_1c_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Creating Security Group for Instances
resource "aws_security_group" "prosg" {
  name        = "prosg"
  vpc_id      = aws_vpc.provpc.id
  description = "Security Group for public instances"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Creating Java Instance in Availability Zone ap-south-1a
resource "aws_instance" "java_First_Instance" {
  ami                         = "ami-0f58b397bc5c1f2e8"  # Verify this AMI ID
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.aval_1a_subnet.id
  vpc_security_group_ids      = [aws_security_group.prosg.id]
  associate_public_ip_address = true
  key_name                    = "hhkey"  # Ensure this key pair exists
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y openjdk-11-jdk
              EOF
  tags = {
    Name = "javaFirstInstance"
  }
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
