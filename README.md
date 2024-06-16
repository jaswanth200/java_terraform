# Terraform AWS Infrastructure

This Terraform configuration sets up an AWS VPC with subnets across multiple availability zones, an internet gateway, route tables with associations, a security group, and deploys an EC2 instance running a Java environment.

## Prerequisites

Before you begin, ensure you have the following:
- Terraform >= 1.0.0 installed
- AWS IAM credentials configured locally or through environment variables

## Configuration Details

### Terraform Version

```
terraform {
  required_version = ">= 1.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.46.0"
    }
  }
}
'''
AWS Provider
The AWS provider is configured with the region ap-south-1:
