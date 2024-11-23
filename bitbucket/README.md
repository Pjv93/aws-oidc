# Bitbucket OIDC Authentication with AWS

This repository provides a comprehensive solution for securely integrating Bitbucket Pipelines with AWS using OpenID Connect (OIDC). The included CloudFormation templates facilitate dynamic authentication, enabling pipelines to assume AWS roles without static credentials. This setup supports multiple repositories within a single Bitbucket workspace.

---

## Why Use This Setup?

When working with Bitbucket Pipelines, secure access to AWS services is essential for deploying infrastructure, managing S3 storage, or other CI/CD tasks. Traditional methods involve hardcoded access keys, which are challenging to manage and pose security risks. By leveraging OIDC, this template enables:

- **Dynamic Authentication**: Short-lived credentials eliminate the need for static access keys.
- **Improved Security**: AWS issues temporary tokens, reducing the attack surface.
- **Streamlined Management**: No manual key rotation or storage required.

---

## Features

1. **Multi-Repository Support**:
   - Configure multiple repositories within a single Bitbucket workspace.
   - Dynamically updates trust policies for specified repositories.

2. **Granular Access Control**:
   - Define specific repository UUIDs or use wildcards for broader access.
   - Securely grant permissions to AWS resources like S3.

3. **Dynamic Role Configuration**:
   - Uses a Lambda function to process repository UUIDs and dynamically generate IAM trust policies.

4. **Integration with S3**:
   - Grant pipelines access to specific S3 buckets for artifact storage and retrieval.

---

## Files in This Repository

| File Name                             | Description                                                 |
|---------------------------------------|-------------------------------------------------------------|
| `bitbucket-oidc-advanced-template.yaml` | Advanced template for multi-repo setups with dynamic trust policies. |
| `bitbucket-oidc-template.yaml`        | Basic template for single-repository setups.               |
| `bitbucket-pipelines.yml`             | Example Bitbucket Pipelines workflow for AWS integration.  |

---

## Setup Instructions

### Prerequisites

1. **AWS Account**:
   - IAM permissions to deploy resources via CloudFormation.
   - An existing S3 bucket for pipeline artifacts.

2. **Bitbucket Workspace**:
   - Repositories configured with OpenID Connect.
   - UUIDs and Audience values retrieved from repository settings.

3. **AWS CLI**:
   - Installed and configured on your local machine for template deployment.

---

### Step 1: Deploy the CloudFormation Template

#### Advanced Template (`bitbucket-oidc-advanced-template.yaml`)

1. Use the AWS Management Console or CLI to deploy the advanced template.
2. Specify the following parameters:
   - `WorkspaceName`: Your Bitbucket workspace name.
   - `RepositoryUUIDs`: Comma-separated list of repository UUIDs. Use `*` for all repositories.
   - `Audience`: Retrieved from **Repository settings > OpenID Connect > Audience**.
   - `BucketName`: Name of the S3 bucket for pipeline access.
   - `IAMRoleName`: Name of the IAM Role for Bitbucket OIDC.

---

### Step 2: Configure Bitbucket Repositories

1. Navigate to **Repository settings > OpenID Connect** for each repository.
2. Copy the repository's **UUID** and **Audience** values.
3. Update the CloudFormation parameters with these values.

---

### Step 3: Add Secrets to Bitbucket Pipelines

Add the following variables to your Bitbucket repository:

| Variable Name            | Value                                          |
|--------------------------|------------------------------------------------|
| `AWS_ROLE_ARN`           | The ARN of the IAM role created by the template. |
| `AWS_REGION`             | The AWS region for your resources.            |

---

### Step 4: Configure Bitbucket Pipelines Workflow

Example workflow (`bitbucket-pipelines.yml`):

```yaml
image: amazon/aws-cli:2.13.14

pipelines:
  default:
    - step:
        name: Deploy to AWS S3 using OIDC
        oidc: true
        script:
          - export AWS_ROLE_ARN="$AWS_ROLE_ARN"
          - export AWS_DEFAULT_REGION="$AWS_REGION"
          - export AWS_WEB_IDENTITY_TOKEN_FILE="/tmp/aws_web_identity_token"
          - echo $BITBUCKET_STEP_OIDC_TOKEN > $AWS_WEB_IDENTITY_TOKEN_FILE
          - aws sts get-caller-identity
          - aws s3 cp your-local-file.txt s3://YOUR_BUCKET_NAME/


---

## Example Use Cases

### Single Repository Access:
- **Workspace**: `pjv93`
- **RepositoryUUIDs**: `{123e4567-e89b-12d3-a456-426614174000}`
- **Audience**: `ari:cloud:bitbucket::workspace/WORKSPACE_UUID`

### Multi-Repository Access:
- **Workspace**: `pjv93`
- **RepositoryUUIDs**: `{123e4567-e89b-12d3-a456-426614174000},{223e4567-e89b-12d3-a456-426614174001}`
- **Audience**: `ari:cloud:bitbucket::workspace/WORKSPACE_UUID`

### All Repositories in a Workspace:
- **Workspace**: `pjv93`
- **RepositoryUUIDs**: `*`
- **Audience**: `ari:cloud:bitbucket::workspace/WORKSPACE_UUID`

---

## Benefits of OIDC for Bitbucket Pipelines

- **Security**: Eliminates static credentials.
- **Automation**: Credentials are short-lived and issued per pipeline run.
- **Least Privilege**: IAM policies grant scoped permissions.

---

## Outputs

After deploying the template, the following outputs are available:
___________________________________________________________________________
| Output Name      | Description                                          |
|------------------|------------------------------------------------------|
| `IAMRoleArn`     | The ARN of the IAM role for Bitbucket OIDC pipelines.|
___________________________________________________________________________
---

## Support

If you encounter issues or have questions, please raise an issue in this repository. Contributions and suggestions are always welcome!
