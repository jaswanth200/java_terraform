# Terraform AWS Infrastructure

This Terraform configuration sets up a basic AWS infrastructure with a VPC, subnets across multiple availability zones, an internet gateway, route tables, security groups, and deploys an EC2 instance running a Java environment.

## Prerequisites

Before you begin, ensure you have the following installed/configured:

- Terraform >= 1.0.0
- AWS CLI configured with appropriate credentials and default region set to `ap-south-1`
- (Optional) Key pair (`hhkey`) for SSH access to the EC2 instance

## Getting Started

1. Clone this repository:

   ```bash
   git clone <repository-url>
   cd <repository-name>
   '''
