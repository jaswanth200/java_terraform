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
- [License](#license)

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

# Terraform Deployment for AWS Infrastructure

This Terraform script automates the deployment of an AWS infrastructure with a load balancer and auto-scaling group for a Java application.

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

## Usage

1. **Configure Terraform Backend**: Ensure proper configuration of the Terraform backend to store state files securely.
   
2. **Set AWS Credentials**: Ensure AWS credentials are set up correctly to allow Terraform to authenticate and deploy resources.
   
3. **Customize Variables**: Modify variables (`asgmin`, `asgmax`, `asgdesired`) as per your scaling requirements and environment setup.
   
4. **Execute Terraform Commands**: Run `terraform init` to initialize the working directory and then `terraform apply` to apply the changes and deploy the infrastructure.

## Notes

- Ensure proper network connectivity and security group configurations to allow traffic to flow correctly between components.
- Monitor AWS costs associated with running instances, load balancer usage, and other AWS resources created by this script.

This README.md file provides an overview of the Terraform script for deploying an AWS infrastructure with a load balancer and auto-scaling group. Customize it according to your specific project's requirements and configurations.

# Terraform Outputs Documentation

This section outlines the outputs generated by the Terraform script after deploying the AWS infrastructure components.

## Outputs

The following outputs are available after running the Terraform configuration:

### Java First Instance AMI

- **Description**: AMI ID of the Java first instance.
- **Output Name**: `java_first_instance_ami`
- **Value**: `aws_ami_from_instance.java_First_Instance_ami.id`

### Java First Instance Public IP

- **Description**: Public IP address of the Java first instance.
- **Output Name**: `java_first_instance_ip`
- **Value**: `aws_instance.java_First_Instance.public_ip`

### Production VPC ID

- **Description**: ID of the production Virtual Private Cloud (VPC).
- **Output Name**: `provpc`
- **Value**: `aws_vpc.provpc.id`

### Production Internet Gateway ID

- **Description**: ID of the internet gateway attached to the production VPC.
- **Output Name**: `proig`
- **Value**: `aws_internet_gateway.proig.id`

### Availability Zone 1a Subnet ID

- **Description**: ID of the subnet in Availability Zone 1a.
- **Output Name**: `aval_1a_subnet`
- **Value**: `aws_subnet.aval_1a_subnet.id`

### Availability Zone 1b Subnet ID

- **Description**: ID of the subnet in Availability Zone 1b.
- **Output Name**: `aval_1b_subnet`
- **Value**: `aws_subnet.aval_1b_subnet.id`

### Availability Zone 1c Subnet ID

- **Description**: ID of the subnet in Availability Zone 1c.
- **Output Name**: `aval_1c_subnet`
- **Value**: `aws_subnet.aval_1c_subnet.id`

### Production Security Group ID

- **Description**: ID of the security group created for production.
- **Output Name**: `prosg`
- **Value**: `aws_security_group.prosg.id`

## Usage

- Use these outputs in subsequent Terraform configurations by referencing them as `data.terraform_remote_state.networking.outputs.<output_name>`.
- Alternatively, these outputs can be used in external scripts or tools for integrating with other systems or for informational purposes.

## Notes

- Ensure that these outputs are correctly configured and accessible for any downstream configurations or scripts that depend on them.
- Consider securing access to these outputs as they may contain sensitive information like instance IPs or VPC IDs.

This README.md provides documentation for the outputs generated by the Terraform script. Customize it according to your specific project's requirements and environment setup.


# Jenkins Pipeline for Deploying Java Application

This Jenkins pipeline script automates the deployment of a Java application to a remote VM. It performs the following steps:

1. **Getting tar file from Nexus**: Downloads a tar file from Nexus repository using SSH and curl.
2. **Unarchive the tar file**: Unarchives the downloaded tar file on the remote VM and installs OpenJDK 11.
3. **Run the Java Application**: Executes the Java application with specified arguments on the remote VM.

## Prerequisites

Before running this Jenkins pipeline, ensure:

- Jenkins is set up and configured with necessary plugins (e.g., SSH, Git).
- Nexus repository URL (`nexus_ip_address:8081/repository/maven-repo`) is accessible.
- Remote VM (`remote_vm_ip_address`) is configured to allow SSH connections and has Java dependencies resolved.

## Pipeline Structure

The pipeline is structured into three stages:

### 1. Getting tar file from Nexus

Downloads the tar file from Nexus repository using SSH and curl.

### 2. Unarchive the tar file

Unarchives the tar file on the remote VM and installs OpenJDK 11.

### 3. Run the Java Application

Executes the Java application with specified arguments on the remote VM.

## Pipeline Script

```groovy
pipeline {
    agent any
    
    stages {
        stage('Getting tar file from Nexus') {
            steps {
                script {
                    sh """
                        ssh ubuntu@${remote_vm_ip_address} 'curl -u jashu:12345 -O -L http://nexus_ip_address:8081/repository/maven-repo/javatar.${img_tag}.tar'
                    """
                }
            }
        }
        
        stage('Unarchive the tar file') {
            steps {
                script {
                    sh """
                        ssh ubuntu@${remote_vm_ip_address} 'tar -xvf javatar.img_tag.tar && cd demo-backend1/target'
                    """
                    sh """
                        ssh ubuntu@${remote_vm_ip_address} 'sudo apt update && sudo apt install -y openjdk-11-jdk'
                    """
                }
            }
        }
        
        stage('Run the Java Application') {
            steps {
                script {
                    sh """
                        ssh ubuntu@${remote_vm_ip_address} 'cd demo-backend1/target && java -jar /home/ubuntu/demo-backend1/target/sentiment-analysis-web-0.0.2-SNAPSHOT.jar --sa.logic.api.url=http://localhost:5000'
                    """
                }
            }
        }
    }
}

