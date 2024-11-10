# GitHub Actions with AWS OIDC Authentication

This repository demonstrates how to securely authenticate GitHub Actions with AWS using OpenID Connect (OIDC). By leveraging OIDC, GitHub Actions can assume roles in AWS without static credentials, making AWS access for CI/CD workflows safer, simpler, and more manageable.

## Why Use This Setup?

When automating workflows with GitHub Actions, accessing AWS services is often necessary for tasks like deploying infrastructure, managing S3 storage, or interacting with ECR for container builds. Traditionally, AWS access required **hardcoded access keys**, which present challenges:

1. **Security Risks of Static Credentials**: Hardcoded credentials in GitHub Actions pose security risks, as they can be exposed if not stored securely. They also require manual rotation every 90 days, increasing the risk of accidental exposure.

2. **Manual Management Overhead**: Maintaining and rotating access keys involves extra management, particularly if workflows need to access AWS frequently. This can be both time-consuming and error-prone.

3. **Lack of Automation**: Hardcoded keys are static and do not benefit from the inherent security of AWS’s dynamic credentials, such as temporary tokens provided by AWS IAM roles.

### The OIDC Solution

With **OIDC (OpenID Connect)**, AWS allows GitHub Actions to securely assume roles without static credentials. This setup establishes a **trusted connection between GitHub and AWS**, providing temporary, short-lived credentials dynamically at each workflow run. Here’s why this matters:

- **Enhanced Security**: AWS manages credential rotation, issuing fresh, short-lived tokens for each workflow. This eliminates the need for static credentials in GitHub Actions, reducing the risk of exposure.
- **Streamlined Management**: Using IAM roles with OIDC means no more manual credential rotation. Once set up, GitHub Actions seamlessly authenticates with AWS, without further access key management.
- **Fine-Grained Permissions**: You can specify exact permissions in the IAM role and policy, applying the principle of least privilege to ensure GitHub Actions only has the access it needs.

## Overview of the Setup

This setup consists of:
1. **GitHub Actions Workflow** (`github-action-demo.yaml`) - A sample workflow demonstrating how to authenticate with AWS using OIDC and perform basic AWS operations (fetching caller identity, listing S3 buckets).
2. **AWS CloudFormation Template** - Defines the IAM roles and policies that enable GitHub Actions to authenticate with AWS via OIDC, providing secure access with managed permissions.

## Prerequisites

- An AWS account with permissions to deploy IAM roles and policies via CloudFormation.
- GitHub repository with secrets configured for AWS access (explained below).

## Setup Instructions

### Step 1: Deploy the CloudFormation Stack

1. Use the provided CloudFormation template to deploy the necessary AWS resources:
   - **OIDC Provider**: Establishes a trust relationship between GitHub and AWS.
   - **GitHubActionsRole**: An IAM role with permissions that GitHub Actions can assume using OIDC.

2. Update the `GitHubActionsRole` settings:
   - Modify the **StringLike condition** in the role’s trust policy to control which GitHub repositories or organizations are allowed to assume this role. The **StringLike** condition provides flexibility to specify:
   
     - **A Specific Repository**: To restrict access to a single repository, set the condition to `token.actions.githubusercontent.com:sub` with a value like `repo:org-name/repo-name:*`. For example, `repo:my-org/my-repo:*` would allow only workflows within the `my-repo` repository in `my-org` to assume this role.
     
     - **An Entire Organization**: To allow all repositories within an organization, use a wildcard in place of the repository name. For example, `repo:my-org/*` allows any repository within the `my-org` organization to assume this role, enabling workflows from multiple repositories to use it if needed.
     
     - **Fine-Tuned Repository Access**: The `StringLike` condition also supports specifying branches or tags for even more granular control. For instance, `repo:org-name/repo-name:refs/heads/main` restricts access to only the `main` branch of `repo-name` in `org-name`.

This approach allows you to control access precisely, ensuring that only the intended repositories or branches can assume the role, which helps reinforce security and maintain control over AWS resources.


### Step 2: Set Up GitHub Secrets

To allow GitHub Actions to assume the specified AWS role, set up these secrets in your GitHub repository:

1. Go to **Settings** > **Secrets and variables** > **Actions** in your GitHub repository.
2. Click **New repository secret** and add:
   - **AWS_ACCOUNT_ROLE**: The ARN of the IAM role created in AWS (e.g., `arn:aws:iam::account-id:role/GitHub_Actions_Role`).
   - **AWS_REGION**: The AWS region where your resources are located.

### Step 3: Configure the GitHub Actions Workflow

The GitHub Actions workflow file (`github-action-demo.yaml`) includes a job that authenticates with AWS using OIDC and performs the following actions:
1. **Configure AWS Credentials**: Uses the AWS OIDC token to assume the specified role.
2. **Fetch Caller Identity**: Runs `aws sts get-caller-identity` to verify the AWS identity.
3. **List S3 Buckets**: Runs `aws s3 ls` to list S3 buckets in the specified AWS account.

To execute the workflow:
- This workflow runs on pushes to the `main` branch, pull requests to `main`, or can be manually triggered.

### Benefits of Using OIDC for GitHub Actions and AWS

1. **No Static Credentials**: With OIDC, credentials are dynamically generated by AWS, so there are no long-lived access keys to manage or secure.
2. **Automatic Credential Rotation**: AWS issues short-lived tokens, which means credentials are automatically rotated and renewed for each workflow, reducing the risk of credential leaks.
3. **Least Privilege Access**: The IAM role used by GitHub Actions can be tailored with specific permissions for each AWS service or operation, enhancing security by restricting unnecessary access.
4. **Seamless Integration**: OIDC provides a simple, secure way to integrate GitHub Actions with AWS without extra configuration or credential management.

## Example Permissions in the GitHubActionsManagedPolicy

The managed policy attached to the `GitHubActionsRole` includes example permissions for:

- **S3 Bucket Access**:
  - **Bucket-level**: Allows listing and getting the bucket location.
  - **Object-level**: Provides permissions to put, get, and delete objects within a specified bucket.

- **Additional AWS Services**:
  - To expand this setup, you can add permissions for other services, such as ECR for Docker images. Examples are provided in the policy for easy customization.

## Conclusion

This OIDC setup provides a modern, secure way for GitHub Actions to authenticate with AWS without static credentials. By using short-lived tokens, this configuration reduces the risk of credential leakage, streamlines access management, and enhances the security of AWS-integrated workflows.
