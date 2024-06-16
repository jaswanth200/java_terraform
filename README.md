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

# Jenkins Pipeline for Terraform

This Jenkins pipeline is designed to automate the initialization and application of Terraform configurations.

## Table of Contents

- [Overview](#overview)
- [Pipeline Stages](#pipeline-stages)
- [Requirements](#requirements)
- [Setup](#setup)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
## Overview

This pipeline consists of two stages:
1. **Terraform Init**: Initializes the Terraform configuration.
2. **Terraform Apply**: Applies the Terraform configuration with automatic approval.

The pipeline assumes that the Terraform configurations are located in the `file1` directory.

## Pipeline Stages

### Terraform Init

- **Purpose**: Initializes the Terraform working directory with the latest module versions.
- **Command**: `terraform init -upgrade`
- **Location**: `file1` directory.

### Terraform Apply

- **Purpose**: Applies the Terraform configuration to provision infrastructure.
- **Command**: `terraform apply -auto-approve`
- **Location**: `file1` directory.

## Requirements

- **Jenkins**: Make sure Jenkins is installed and running.
- **Terraform**: Terraform must be installed on the Jenkins agent.

## Setup

### Jenkins Configuration

1. **Create a Jenkins Pipeline Job**:
    - Open Jenkins and create a new pipeline job.
    - Copy and paste the provided pipeline script into the job configuration.

2. **Configure Jenkins Credentials** (if necessary):
    - Ensure that any necessary credentials (e.g., cloud provider credentials) are configured in Jenkins.

3. **Install Terraform**:
    - Ensure Terraform is installed on the Jenkins agent. You can install it from the [Terraform website](https://www.terraform.io/downloads.html).

4. **Pipeline Script**:
    - Below is the pipeline script to be used:

    ```groovy
    pipeline {
        agent any
        
        stages {
            stage('Terraform Init') {
                steps {
                    dir('file1') {
                        script {
                            sh 'terraform init -upgrade'
                        }
                    }
                }
            }

            stage('Terraform Apply') {
                steps {
                    dir('file1') {
                        script {
                            sh 'terraform apply -auto-approve'
                        }
                    }
                }
            }
        }
    }
    ```

## Usage

### Running the Pipeline

1. **Trigger the Build**:
    - Go to the Jenkins job you created and click **"Build Now"**.
    - Monitor the build progress in the Jenkins console output.

2. **Pipeline Stages**:
    - The pipeline will execute the `Terraform Init` stage to initialize the configuration.
    - Upon successful initialization, it will proceed to the `Terraform Apply` stage to apply the configuration.

### Example Output

- **Terraform Init**:
    ```
    Initializing the backend...
    Initializing provider plugins...
    Terraform has been successfully initialized!
    ```
- **Terraform Apply**:
    ```
    Applying changes...
    Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
    ```

## Troubleshooting

- **Common Issues**:
    - **Terraform Not Found**: Ensure Terraform is installed and accessible from the Jenkins agent.
    - **Permission Denied**: Verify that Jenkins has the necessary permissions to execute Terraform commands.

- **Logs**:
    - Check the Jenkins console output for detailed logs if the build fails.

## Contributing

We welcome contributions to improve this pipeline. Please follow these steps:

1. **Fork the Repository**: Create a fork on GitHub.
2. **Create a New Branch**: Use a descriptive branch name, e.g., `feature/add-logging`.
3. **Make Changes**: Implement your changes.
4. **Submit a Pull Request**: Create a pull request to merge your changes into the main repository.


# Jenkins Pipeline for Deploying Java Application to Remote VM

This Jenkins pipeline automates the deployment of a Java application from a Nexus repository to a remote VM, setting up OpenJDK 11, and running the application.

## Table of Contents

- [Overview](#overview)
- [Pipeline Stages](#pipeline-stages)
- [Requirements](#requirements)
- [Setup](#setup)
- [Usage](#usage)
- [Troubleshooting](#troubleshooting)
- [Contributing](#contributing)
## Overview

This pipeline consists of three stages:
1. **Getting tar file from Nexus**: Downloads a tar file containing the Java application from Nexus using SSH and curl.
2. **Unarchive the tar file**: Unarchives the downloaded tar file on the remote VM, installs OpenJDK 11, and prepares the application.
3. **Run the JAVA APPLICATION**: Runs the Java application with specified arguments on the remote VM.

The pipeline assumes SSH access to the remote VM (`ubuntu@${remote_vm_ip_address}`) and credentials (`jashu:12345`) for Nexus repository access.

## Pipeline Stages

### Getting tar file from Nexus

# Pipeline Description

This pipeline is designed to deploy a Java application on a remote VM after fetching a tar file from a Nexus repository.

## Pipeline Structure

The pipeline consists of the following stages:

### Stage 1: Getting tar file from Nexus

This stage downloads a tar file containing the Java application from a Nexus repository using SSH and curl.

### Stage 2: Unarchive the tar file

This stage unarchives the downloaded tar file on the remote VM and prepares the environment by installing OpenJDK 11.

### Stage 3: Run the Java application

Finally, this stage executes the Java application on the remote VM with specified arguments.

## Pipeline Script

```groovy
pipeline {
    agent any

    stages {
        stage('Getting tar file from Nexus') {
            steps {
                script {
                    // Download the tar file from Nexus repository using SSH and curl
                    sh """
                        ssh ubuntu@${remote_vm_ip_address} 'curl -u jashu:12345 -O -L http://nexus_ip_address:8081/repository/maven-repo/javatar.${img_tag}.tar'
                    """
                }
            }
        }

        stage('Unarchive the tar file') {
            steps {
                script {
                    // Unarchive the tar file on the remote VM
                    sh """
                        ssh ubuntu@${remote_vm_ip_address} 'tar -xvf javatar.img_tag.tar && cd demo-backend1/target'
                    """
                    // Install OpenJDK 11 on the remote VM
                    sh """
                        ssh ubuntu@${remote_vm_ip_address} 'sudo apt update && sudo apt install -y openjdk-11-jdk'
                    """
                }
            }
        }

        stage('Run the JAVA APPLICATION') {
            steps {
                script {
                    // Run the Java application with specified arguments
                    sh """
                        ssh ubuntu@${remote_vm_ip_address} 'cd demo-backend1/target && java -jar /home/ubuntu/demo-backend1/target/sentiment-analysis-web-0.0.2-SNAPSHOT.jar --sa.logic.api.url=http://localhost:5000'
                    """
                }
            }
        }
    }
}

