# Terraform AWS Infrastructure

This Terraform configuration sets up an AWS VPC with subnets across multiple availability zones, an internet gateway, route tables with associations, a security group, and deploys an EC2 instance running a Java environment.

## Prerequisites

Before you begin, ensure you have the following:
- Terraform >= 1.0.0 installed
- AWS IAM credentials configured locally or through environment variables

## Configuration Details

### Terraform Version

This configuration specifies Terraform version and required provider version constraints:

```hcl
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0"
    }
  }
}
###AWS Provider
The AWS provider is configured with the region ap-south-1:
provider "aws" {
  region = "ap-south-1"
}
'''hcl
**Resources Created**
VPC (aws_vpc.provpc)
CIDR Block: 10.10.0.0/16
Tags: Name: provpc
Internet Gateway (aws_internet_gateway.proig)
Attached to VPC: aws_vpc.provpc
Tags: Name: proig
Subnets
Three subnets created across different availability zones (ap-south-1a, ap-south-1b, ap-south-1c):

Subnet 1 (aws_subnet.aval_1a_subnet):

CIDR Block: 10.10.1.0/24
Availability Zone: ap-south-1a
Tags: Name: aval_1a_subnet
Subnet 2 (aws_subnet.aval_1b_subnet):

CIDR Block: 10.10.2.0/24
Availability Zone: ap-south-1b
Tags: Name: aval_1b_subnet
Subnet 3 (aws_subnet.aval_1c_subnet):

CIDR Block: 10.10.3.0/24
Availability Zone: ap-south-1c
Tags: Name: aval_1c_subnet
Route Table (aws_route_table.public_rt)
Associated with VPC: aws_vpc.provpc
Route to Internet Gateway (aws_internet_gateway.proig)
Tags: Name: public_rt
Route Table Associations
Associations of subnets with the public route table:

Subnet 1a: aws_subnet.aval_1a_subnet
Subnet 1b: aws_subnet.aval_1b_subnet
Subnet 1c: aws_subnet.aval_1c_subnet
Security Group (aws_security_group.prosg)
Name: prosg
Description: Security Group for public instances
Ingress Rules:
Allow TCP port 80 (HTTP) from anywhere
Allow TCP port 22 (SSH) from anywhere
Egress Rule: Allow all outbound traffic to anywhere
EC2 Instance (aws_instance.java_First_Instance)
AMI: ami-0f58b397bc5c1f2e8
Instance Type: t2.micro
Subnet: aws_subnet.aval_1a_subnet
Security Group: aws_security_group.prosg
Public IP: Enabled
User Data: Installs OpenJDK 11
Tags: Name: javaFirstInstance
AMI from Instance (aws_ami_from_instance.java_First_Instance_ami)
Name: Dynamically generated with timestamp
Source Instance: aws_instance.java_First_Instance
Tags: Name: java_FirstInstanceAMI
