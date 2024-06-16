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

