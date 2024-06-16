# Terraform AWS Infrastructure

This Terraform configuration sets up a basic AWS infrastructure with a VPC, subnets across multiple availability zones, an internet gateway, route tables, security groups, and deploys an EC2 instance running a Java environment.

## Prerequisites

Before you begin, ensure you have the following installed/configured:

- Terraform >= 1.0.0
- AWS CLI configured with appropriate credentials and default region set to `ap-south-1`
- (Optional) Key pair (`hhkey`) for SSH access to the EC2 instance

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
```
### AWS Provider
The AWS provider is configured with the region ## ap-south-1:
```
provider "aws" {
  region = "ap-south-1"
}
```
