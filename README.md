# AWS CI/CD Authentication Solutions

This repository contains two setups to securely authenticate CI/CD workflows with AWS services, one for **GitHub Actions** and one for **Jenkins**. Both setups eliminate the need for static credentials, enhancing security and simplifying AWS access management for CI/CD workflows.

## Overview

1. **GitHub Actions with AWS OIDC Authentication**:  
   - Uses OpenID Connect (OIDC) to securely authenticate GitHub Actions workflows with AWS.
   - Enables temporary, short-lived credentials for GitHub Actions without requiring hardcoded access keys.
   - Includes a CloudFormation template that sets up an OIDC provider and a GitHub-specific IAM role for controlled AWS access.
   - [Go to the GitHub Actions OIDC Setup](./aws-github-oidc)

2. **Jenkins with AWS Systems Manager Hybrid Activation**:  
   - Uses AWS Systems Manager (SSM) hybrid activations to securely register an on-premises Jenkins server with AWS.
   - Allows Jenkins to assume an AWS IAM role and securely access AWS services without hardcoded credentials.
   - Provides a CloudFormation template and setup script to automate the SSM registration and configuration process.
   - [Go to the Jenkins Hybrid Activation Setup](./jenkins)

## Prerequisites

Before you begin, make sure you have:

- **AWS IAM Permissions**: Permissions to create IAM roles, policies, and OIDC providers via CloudFormation.
- **Admin Access to GitHub or Jenkins**: Ensure you have the necessary permissions in your GitHub repository or Jenkins server to configure secrets and credentials.
- **AWS CLI**: For deploying CloudFormation stacks from the command line, ensure the AWS CLI is installed and configured.

## Why Use These Setups?

When working with AWS from external CI/CD systems, securely managing AWS credentials is critical. Static credentials can lead to security risks and increase management overhead, as they require regular rotation and secure storage. These solutions provide:

- **Dynamic Credential Management**: Both setups use role assumption for temporary credentials, which AWS rotates automatically. This removes the need for static access keys.
- **Enhanced Security**: By using IAM roles with fine-grained permissions, these setups follow the principle of least privilege, reducing the risk of overexposed access.
- **Simplified Workflow Integration**: These solutions are tailored for common CI/CD systems (GitHub Actions and Jenkins), making it easy to integrate AWS access into your workflows.

## Getting Started

To set up and configure each system, navigate to the respective folder:

- **[GitHub Actions with AWS OIDC Authentication](./aws-github-oidc)**: Provides instructions for setting up GitHub Actions to authenticate with AWS using OIDC.
- **[Jenkins with AWS Systems Manager Hybrid Activation](./jenkins)**: Includes setup details for using AWS SSM hybrid activation to register a Jenkins server with AWS.

Each folder contains a detailed README with prerequisites, setup instructions, and examples for using the configured IAM roles in your workflows.

## Next Steps and Customization Tips

Once you’ve set up the basic configuration, consider extending or customizing these setups based on your needs:

- **Fine-Tune IAM Permissions**: Adjust IAM policies to limit access to only the AWS services your workflows require. This reduces the potential security risk of over-permissioned roles.
- **Add More AWS Services**: Customize the setup to include additional AWS services in your workflows, such as Lambda or DynamoDB, for more complex CI/CD pipelines.

## Troubleshooting and Common Issues

If you encounter issues, here are a few common troubleshooting tips:

- **Check AWS Secrets**: Ensure the `AWS_REGION` and `AWS_ACCOUNT_ROLE` secrets are correctly set in your GitHub repository.
- **Verify SSM Agent Connectivity**: For Jenkins setups, confirm the SSM Agent can connect to AWS. If the Jenkins server is behind a firewall, ensure the necessary ports are open.
- **Inspect IAM Permissions**: If access is denied in GitHub Actions or Jenkins, review and adjust the IAM permissions attached to the roles in each setup.
  
