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
# Terraform Deployment for AWS Infrastructure

This Terraform script automates the deployment of an AWS infrastructure with a load balancer, auto-scaling group, and related resources.

## Prerequisites

Before running this Terraform script, ensure:

- Terraform CLI is installed (`>= 1.0.0` recommended).
- AWS credentials are configured either through environment variables or shared credentials file.
- Necessary permissions are granted for creating resources like VPC, subnets, security groups, load balancer, and auto-scaling groups.

## Terraform Configuration

### Providers

This script utilizes the following Terraform provider:

- **AWS Provider**: Configured to deploy resources in the `ap-south-1` region.

### Data Sources

This script uses a Terraform `terraform_remote_state` data source to retrieve outputs from a previously deployed infrastructure configuration:

- **Networking**: Retrieves VPC ID, subnets, security groups, and AMI information from the specified Terraform state file (`/var/lib/jenkins/workspace/Java_Terraform_VM_Create/file1/terraform.tfstate`).

### Resources

#### Load Balancer Security Group

Creates a security group (`aws_security_group.lbsg`) for the load balancer allowing HTTP traffic:

- Allows incoming HTTP traffic (`TCP port 80`) from the internet (`0.0.0.0/0`).
- Allows outgoing HTTP traffic to the internet.

#### Load Balancer

Creates an AWS Application Load Balancer (`aws_lb.prolb`):

- Configured with the security group (`aws_security_group.lbsg`).
- Spread across specified subnets (`data.terraform_remote_state.networking.outputs.aval_1a_subnet`, `aval_1b_subnet`, `aval_1c_subnet`).
- Tagged with `Environment: production`.

#### Load Balancer Listener

Creates a listener (`aws_lb_listener.prolb_listener`) for the load balancer:

- Listens on port `80` for HTTP traffic.
- Forwards traffic to the target group (`aws_lb_target_group.prolb_targetgroup`).

#### Target Group

Defines a target group (`aws_lb_target_group.prolb_targetgroup`) for the load balancer:

- Listens on port `80` for HTTP traffic.
- Associated with the VPC (`data.terraform_remote_state.networking.outputs.provpc`).

#### Auto Scaling

Creates an auto-scaling group (`aws_autoscaling_group.prod_auto_scale_grp`) with a launch configuration (`aws_launch_configuration.pro_aws_asg_config`):

- Launches instances with the specified AMI (`data.terraform_remote_state.networking.outputs.java_first_instance_ami`), instance type (`t2.micro`), key pair (`hhkey`), and security groups.
- Configured to operate between `1` and `5` instances (`var.asgmin`, `asgmax`), with `1` desired.
- Utilizes the load balancer (`aws_lb.prolb`) for health checks.
- Spans across specified subnets (`aval_1a_subnet`, `aval_1b_subnet`, `aval_1c_subnet`).
- Defines instance maintenance policies for health monitoring.
- Tags instances with `vv: bar` upon launch.

### Variables

This script defines the following variables:

- **asgmin**: Minimum number of instances in the auto-scaling group (default: `1`).
- **asgmax**: Maximum number of instances in the auto-scaling group (default: `5`).
- **asgdesired**: Desired number of instances in the auto-scaling group (default: `1`).

## Outputs

The script generates the following outputs after applying:

- **Java First Instance AMI**: AMI ID of the Java first instance.
- **Java First Instance Public IP**: Public IP address of the Java first instance.
- **Production VPC ID**: ID of the production Virtual Private Cloud (VPC).
- **Production Internet Gateway ID**: ID of the internet gateway attached to the production VPC.
- **Availability Zone 1a Subnet ID**: ID of the subnet in Availability Zone 1a.
- **Availability Zone 1b Subnet ID**: ID of the subnet in Availability Zone 1b.
- **Availability Zone 1c Subnet ID**: ID of the subnet in Availability Zone 1c.
- **Production Security Group ID**: ID of the security group created for production.

## Usage

1. **Configure Terraform Backend**: Ensure proper configuration of the Terraform backend to store state files securely.
   
2. **Set AWS Credentials**: Ensure AWS credentials are set up correctly to allow Terraform to authenticate and deploy resources.
   
3. **Customize Variables**: Modify variables (`asgmin`, `asgmax`, `asgdesired`) as per your scaling requirements and environment setup.
   
4. **Execute Terraform Commands**: Run `terraform init` to initialize the working directory and then `terraform apply` to apply the changes and deploy the infrastructure.

## Notes

- Ensure proper network connectivity and security group configurations to allow traffic to flow correctly between components.
- Monitor AWS costs associated with running instances, load balancer usage, and other AWS resources created by this script.

This README.md provides documentation for the Terraform script deploying an AWS infrastructure with a load balancer and auto-scaling group. Customize it according to your specific project's requirements and environment setup.
