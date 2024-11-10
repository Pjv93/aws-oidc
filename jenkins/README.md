# Jenkins AWS SSM Hybrid Activation with EKS and ECR Access

This repository provides a secure integration solution for on-premises Jenkins servers to access AWS resources without hardcoded credentials. Using AWS Systems Manager (SSM) hybrid activations, Jenkins can assume an AWS IAM role to interact with services like S3, ECR, and EKS, enabling a secure and automated CI/CD environment.

## Overview

For teams running Jenkins on-premises, this solution enables AWS role access without the need for embedded credentials. The setup relies on:

1. **SSM Hybrid Activation** - Secure registration of on-premises servers with AWS Systems Manager.
2. **IAM Roles for Jenkins** - Permissions for AWS services access (S3, ECR, EKS) through role assumption.
3. **Lambda-Based Activation Management** - Automated SSM activation creation and management for seamless server registration.

## Prerequisites

- AWS CLI access for stack deployment
- Permissions to create IAM roles and CloudFormation stacks
- Jenkins server access to execute setup scripts

## Setup Instructions

### Step 1: Deploy CloudFormation Stack

1. Deploy the CloudFormation stack using the provided `jenkins-aws-ssm-hybrid-activation.yaml` template.
2. After deployment, note the **ActivationId** and **ActivationCode** from the stack outputs. These will be used for server registration.

### Step 2: Configure Jenkins Server(s)

Run the shell script (`install-ssm.sh`) on each Jenkins server to:

- Install or update the AWS CLI.
- Detect Linux distribution and install SSM Agent according to system architecture.
- Register the server with AWS SSM using the ActivationId and ActivationCode.

To execute the script:

```bash
bash install-ssm.sh
```

The script will prompt for **AWS Region**, **ActivationId**, and **ActivationCode**.

### Step 3: Configure CI/CD Pipelines

Configure Jenkins pipelines to assume the `JenkinsAccessRole` to securely interact with AWS resources, leveraging SSM and IAM without hardcoded credentials.

### Key CloudFormation Components

- **SSM Service Role**: Enables secure hybrid activation for Jenkins through AWS SSM.
- **Jenkins Role**: Provides permissions for accessing S3, ECR, and EKS.
- **Lambda Function**: Automates SSM activation creation, ensuring temporary access and secure server registration.

### Outputs

The stack outputs the following values:

- **SSMServiceRoleArn**: ARN for SSM Service Role.
- **JenkinsRoleArn**: ARN for Jenkins IAM Role.
- **ActivationId** and **ActivationCode**: Used for secure SSM registration of on-premises servers.
- **RegistrationLimit**: Defines the maximum number of servers for activation.

### Important Notes

- **Credential-Free Access**: This solution eliminates the need for hardcoded AWS credentials, enhancing security by using AWS Systems Manager for role assumption.
- **Permissions Management**: Ensure the `JenkinsAccessRole` permissions are aligned with the specific needs of your pipelines, following the principle of least privilege.
- **Automated Key Rotation**: The setup enables auto-rotation of private keys, further securing Jenkins server access to AWS.
