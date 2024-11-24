# AWS CI/CD Authentication Solutions

This repository provides solutions to securely authenticate various CI/CD platforms with AWS services. It eliminates the need for static credentials, enhancing security and simplifying AWS access management for your workflows.

---

## Architecture Diagram

![Architecture Diagram](/static/architecture-diagram-oidc.png)

---

## Supported CI/CD Platforms

1. **CircleCI with AWS OIDC Authentication**  
   - Leverages OpenID Connect (OIDC) to enable secure, dynamic authentication between CircleCI pipelines and AWS.
   - Provides a CloudFormation template for setting up an OIDC provider and IAM roles with precise access control.
   - [Go to the CircleCI OIDC Setup](./circle-ci)

2. **GitHub Actions with AWS OIDC Authentication**  
   - Uses OIDC to securely authenticate GitHub Actions workflows with AWS.
   - Includes a CloudFormation template to set up an OIDC provider and GitHub-specific IAM roles for controlled AWS access.
   - [Go to the GitHub Actions OIDC Setup](./aws-github-oidc)

3. **Bitbucket Pipelines with AWS OIDC Authentication**  
   - Integrates Bitbucket Pipelines with AWS using OIDC for temporary, secure credentials.
   - Provides a CloudFormation template for configuring an OIDC provider and IAM roles with fine-grained permissions.
   - [Go to the Bitbucket OIDC Setup](./bitbucket)

4. **GitLab CI/CD with AWS OIDC Authentication**  
   - Uses OIDC to connect GitLab pipelines securely to AWS.
   - Supports single and multi-project setups via dynamic configuration and IAM roles.
   - [Go to the GitLab OIDC Setup](./gitlab)

5. **Jenkins with AWS Systems Manager Hybrid Activation**  
   - Uses AWS Systems Manager (SSM) hybrid activations to securely register an on-premises Jenkins server with AWS.
   - Provides a CloudFormation template and setup script for SSM registration and configuration.
   - [Go to the Jenkins Hybrid Activation Setup](./jenkins)

---

## Prerequisites

Before starting, ensure the following:

- **AWS IAM Permissions**: Permissions to create IAM roles, policies, and OIDC providers via CloudFormation.
- **Admin Access to CI/CD Platform**: Ensure you have admin permissions for the respective CI/CD platform (GitHub, Bitbucket, GitLab, CircleCI, or Jenkins).
- **AWS CLI or Console Access**: Deploy CloudFormation stacks using either the AWS CLI or the AWS Management Console.

---

## Why Use These Setups?

Static credentials in CI/CD workflows can lead to:

- **Security Risks**: Hardcoded credentials are prone to leakage.
- **Management Overhead**: Credentials require manual rotation and secure storage.

These solutions address these challenges by providing:

- **Dynamic Credential Management**: Temporary credentials for each pipeline run.
- **Enhanced Security**: Short-lived credentials reduce the risk of leakage.
- **Simplified Integration**: Tailored setups for each CI/CD platform, making configuration straightforward.

---

## Getting Started

To set up and configure a platform, navigate to the respective folder:

- **[CircleCI with AWS OIDC Authentication](./circleci)**: Provides setup details for CircleCI integration.
- **[GitHub Actions with AWS OIDC Authentication](./aws-github-oidc)**: Includes instructions for GitHub OIDC authentication.
- **[Bitbucket Pipelines with AWS OIDC Authentication](./bitbucket)**: Details for Bitbucket integration with AWS.
- **[GitLab CI/CD with AWS OIDC Authentication](./gitlab)**: Step-by-step guide for GitLab OIDC configuration.
- **[Jenkins with AWS Systems Manager Hybrid Activation](./jenkins)**: Instructions for SSM-based Jenkins setup.

Each folder contains:

- Detailed prerequisites for the platform.
- CloudFormation templates and configurations.
- Examples for using IAM roles in pipelines.

---

## Next Steps and Customization Tips

Once you’ve set up the basic configuration, consider extending or customizing these setups based on your needs:

- **Fine-Tune IAM Permissions**: Adjust IAM policies to restrict access to only the AWS services your workflows require.
- **Add More AWS Services**: Expand the setup to include additional AWS services, such as Lambda or DynamoDB, for more complex CI/CD pipelines.
- **Leverage Multi-Project Support**: For platforms like GitLab and Bitbucket, configure multi-project setups with fine-grained branch control.

---

## Troubleshooting and Common Issues

If you encounter issues, here are some common troubleshooting tips:

- **Check AWS Secrets**: Ensure environment variables like `AWS_REGION` and `AWS_ROLE_ARN` are set correctly in your CI/CD platform.
- **Verify OIDC Provider Configuration**: Confirm that the OIDC provider is created in AWS and matches your platform’s settings.
- **Inspect IAM Permissions**: If access is denied, review and adjust the IAM policies attached to the roles.
- **Ensure SSM Connectivity (Jenkins)**: Verify that the SSM Agent on Jenkins can connect to AWS, especially if the server is behind a firewall.

---

## Support

For any issues, questions, or feedback:

- Open an issue in this repository.
- Contributions and suggestions are always welcome!
