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
The AWS provider is configured with the region <b>ap-south-1</b>:
```
provider "aws" {
  region = "ap-south-1"
}
```
### Resources Created
* **VPC (aws_vpc.provpc)**
* **CIDR Block:** 10.10.0.0/16
* **Tags:** Name: provpc
### Internet Gateway (aws_internet_gateway.proig)
* **Attached to VPC:** aws_vpc.provpc
* **Tags:** Name: proig
**Subnets**
Three subnets created across different availability zones (ap-south-1a, ap-south-1b, ap-south-1c):

**1.Subnet 1 (aws_subnet.aval_1a_subnet):**

* **CIDR Block:** 10.10.1.0/24
* **Availability Zone:** ap-south-1a
* **Tags:** Name: aval_1a_subnet

**2.Subnet 2 (aws_subnet.aval_1b_subnet):**
* **CIDR Block:**  10.10.2.0/24
* **Availability Zone:** ap-south-1b
* **Tags:** Name: aval_1b_subnet
  
**3.Subnet 3 (aws_subnet.aval_1c_subnet):**

* **CIDR Block:** 10.10.3.0/24
* **Availability Zone:** ap-south-1c
* **Tags:** Name: aval_1c_subnet
