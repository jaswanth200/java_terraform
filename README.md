AWS Infrastructure with Terraform
=================================
This project provisions an AWS infrastructure using Terraform and deploys a Java application using Jenkins. The infrastructure includes a VPC, subnets, security groups, an internet gateway, and EC2 instances. The Jenkins pipeline is used to automate the provisioning and deployment processes.

Table of Contents
=================
* Project Structure
* Prerequisites
* Setup Instructions
* Terraform Commands
* Jenkins Pipeline
* Outputs

Project Structure
=================
```
├── file1/
│   ├── main.tf
│   ├── outputs.tf
│   └── variables.tf
├── Jenkinsfile1
└── Jenkinsfile2
```

* file1/main.tf: Contains the Terraform configuration for AWS resources.
* file1/outputs.tf: Defines the outputs of the Terraform configuration.
* Jenkinsfile1: Jenkins pipeline for initializing and applying Terraform configuration.
* Jenkinsfile2: Jenkins pipeline for deploying the Java application.

  Prerequisites
  =============
* Terraform (>= 1.0.0)
* AWS account with necessary IAM permissions
* Jenkins
* SSH access to a remote VM for deployment
  
Setup Instructions
==================
# <h3>AWS Setup with Terraform</h3>

# <h3>1. Navigate to the Terraform directory:</h3>
```
cd file1
```
# <h3>2. Initialize Terraform:</h3>
```
terraform init -upgrade
```
# <h3>3. Apply the Terraform configuration:</h3>
```
terraform apply -auto-approve
```
**<h3>4.** Note: Ensure the hhkey SSH key pair exists in your AWS account or modify the main.tf file to use an existing key.</h3>

# <h2>Jenkins Setup</h2>
**1.** Create a Jenkins job for each pipeline using Jenkinsfile1 and Jenkinsfile2.
**2.** Configure the job:
* For Jenkinsfile1, ensure it points to the correct Terraform directory (file1).
* For Jenkinsfile2, replace placeholders (${remote_vm_ip_address}, ${nexus_ip_address}, ${img_tag}) with actual values.
**3.** Run the Jenkins jobs sequentially:
* Start with the job using Jenkinsfile1 to provision AWS resources.
* Then run the job using Jenkinsfile2 to deploy the Java application.
