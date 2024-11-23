# GitLab OIDC Authentication with AWS

This repository provides CloudFormation templates and examples for integrating GitLab CI/CD pipelines with AWS using OpenID Connect (OIDC). By leveraging OIDC, GitLab pipelines can securely authenticate with AWS to perform operations such as deploying infrastructure, accessing S3, and more—without static credentials.

---

## Why Use This Setup?

Traditional authentication methods for CI/CD pipelines often rely on static AWS access keys, which present several challenges:
- **Security Risks**: Hardcoded credentials can be exposed or leaked.
- **Manual Management**: Keys require frequent rotation and secure storage.
- **Lack of Automation**: Static credentials lack the dynamic nature of temporary AWS tokens.

Using OIDC offers:
- **Dynamic Authentication**: Short-lived credentials for every pipeline run.
- **Improved Security**: AWS provides temporary tokens tied to GitLab OIDC identity.
- **Streamlined Management**: No manual key rotation required.

---

## Features

1. **Single or Multi-Project Support**:
   - `oidc-gitlab-template.yaml`: For a single namespace/project setup.
   - `oidc-advanced-template.yaml`: Supports multiple namespaces and repositories.

2. **Granular Access Control**:
   - Restrict access to specific projects or branches.
   - Customize permissions for AWS resources (e.g., S3 buckets).

3. **Seamless Integration with AWS Services**:
   - Access AWS services like S3, Lambda, and CloudFormation directly from GitLab pipelines.

4. **Dynamic Configuration**:
   - Use Lambda functions for multi-repository setups to generate trust policies dynamically.

---

## Files in This Repository

| File Name                       | Description                                                     |
|---------------------------------|-----------------------------------------------------------------|
| `oidc-gitlab-template.yaml`     | Basic template for a single GitLab namespace/project setup.     |
| `oidc-advanced-template.yaml`   | Advanced template for multiple namespaces/projects.            |
| `.gitlab-ci-template.yml`       | Example GitLab CI/CD pipeline for AWS integration.             |

---

## Prerequisites

1. **AWS Account**:
   - IAM permissions to deploy CloudFormation templates.
   - An existing S3 bucket (or other AWS resources) for GitLab to access.

2. **GitLab Project/Group**:
   - The project or namespace should be properly configured for OIDC.

3. **Enable OIDC Integration**:
   - Navigate to **Project Settings > CI/CD > Variables**.
   - Add the following variables:
     1. `AWS_ROLE_ARN`: The ARN of the IAM role created by the CloudFormation template.
     2. `AWS_REGION`: The AWS region where your resources are located.

4. **Enable Pipelines**:
   - Navigate to **Project Settings > CI/CD > Pipelines**.
   - Ensure pipelines are enabled for your project.

5. **AWS CLI**:
   - Installed locally if you plan to deploy the CloudFormation template via CLI.

---

## Step 1: Deploy the CloudFormation Template

### Single Project Setup

Use `oidc-gitlab-template.yaml` for a single namespace/project:
1. Specify the following parameters:
   - `GitLabNamespace`: The namespace or group (e.g., `pjv93`).
   - `GitLabProject`: The project name (e.g., `sample-app`).
   - `GitLabBranch`: The branch to allow access (e.g., `main`, `develop`, or `*` for all branches).
2. Deploy the template using AWS CLI or the AWS Management Console.

### Multi-Project Setup

Use `oidc-advanced-template.yaml` for multiple namespaces/projects:
1. Specify:
   - `GitLabNamespaces`: A comma-separated list of namespaces (e.g., `pjv93,another-group`).
   - `RepositoriesPerNamespace`: Pipe-separated repository lists for each namespace. Use `*` for all repositories.
2. Deploy the template using AWS CLI or the AWS Management Console.

---

## Step 2: Configure GitLab

### Add Variables to Your GitLab Project

1. Navigate to **Project Settings > CI/CD > Variables**.
2. Add the following variables:
   - **`AWS_ROLE_ARN`**: The ARN of the IAM role created by the CloudFormation template.
   - **`AWS_REGION`**: The AWS region where your resources are located.

### Enable Pipelines

1. Navigate to **Project Settings > CI/CD > Pipelines**.
2. Ensure pipelines are enabled for the project.

---

## Step 3: Configure GitLab CI/CD Workflow

Example pipeline configuration (`.gitlab-ci-template.yml`):

```yaml
stages:
  - setup
  - assume-role

setup:
  stage: setup
  image: alpine:latest
  script:
    - echo "Setting up environment..."

assume-role:
  stage: assume-role
  image:
    name: amazon/aws-cli:latest
    entrypoint: [""]
  id_tokens:
    GITLAB_OIDC_TOKEN:
      aud: sts.amazonaws.com  # Ensure consistency with your audience
  variables:
    ROLE_ARN: "${AWS_ROLE_ARN}"
  script:
    - |
      export $(aws sts assume-role-with-web-identity \
        --role-arn "${ROLE_ARN}" \
        --role-session-name "GitLabRunner-${CI_PROJECT_ID}-${CI_PIPELINE_ID}" \
        --web-identity-token "${GITLAB_OIDC_TOKEN}" \
        --duration-seconds 3600 \
        --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' \
        --output text | xargs -n 3 printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s")
    - aws sts get-caller-identity
```

## Outputs

After deploying the template, the following outputs will be available:

| Output Name        | Description                                   |
|--------------------|-----------------------------------------------|
| `OIDCProviderArn`  | The ARN of the GitLab OIDC provider.          |
| `RoleArn`          | The ARN of the IAM role for GitLab pipelines. |

---

## Example Use Cases

### Single Project:
- **Namespace**: `pjv93`
- **Project**: `sample-app`
- **Branch**: `main`

### Multi-Project:
- **Namespaces**: `pjv93,another-group`
- **Repositories**: `repo1,repo2|*`
- **Branch**: All branches (`*`).

---

## Benefits of OIDC with GitLab CI/CD

- **No Static Credentials**: Automatically generated credentials for every pipeline run.
- **Improved Security**: Short-lived credentials reduce the risk of leakage.
- **Dynamic Configuration**: Flexible access control for namespaces, projects, and branches.

---

## Support

For issues, questions, or suggestions, please open an issue in this repository. Contributions are always welcome!
