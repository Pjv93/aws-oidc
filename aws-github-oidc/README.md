# GitHub Actions with AWS OIDC Authentication

This repository demonstrates how to securely authenticate GitHub Actions with AWS using OpenID Connect (OIDC). By leveraging OIDC, GitHub Actions can assume roles in AWS without static credentials, making AWS access for CI/CD workflows safer, simpler, and more manageable.

---

## Why Use This Setup?

When automating workflows with GitHub Actions, accessing AWS services is often necessary for tasks like deploying infrastructure, managing S3 storage, or interacting with ECR for container builds. Traditionally, AWS access required hardcoded access keys, which present challenges:

- **Security Risks of Static Credentials**: Hardcoded credentials in GitHub Actions pose security risks, as they can be exposed if not stored securely. They also require manual rotation every 90 days.
- **Manual Management Overhead**: Rotating and managing access keys manually is error-prone and time-consuming.
- **Lack of Automation**: Static keys lack the inherent security benefits of AWS's dynamic, temporary credentials.

---

## Advanced OIDC Setup: Multi-Org and Multi-Repo Support

This repository includes an enhanced CloudFormation template (`multi-org-oidc-template.yaml`) for advanced setups, which supports:

1. **Multiple GitHub Organizations or Users**:
   - Specify multiple owners (GitHub organizations or users) in the `Owners` parameter.
   - Example:
     - Single owner: `pvass24`
     - Multiple owners: `pvass24,another-org`

2. **Flexible Repository Access**:
   - Specify repositories for each owner in the `RepositoriesPerOwner` parameter.
   - Use a wildcard (`*`) to allow access to all repositories under an owner.
   - Examples:
     - For specific repositories: `Resume,k8s-kadence`
     - For all repositories of `pvass24`: `*`
     - Mixed setup for multiple owners:
       - `RepositoriesPerOwner: "*,k8s-kadence|repo1,repo2"`

3. **Dynamic Configuration**:
   - The template dynamically handles multiple owners and repositories via a custom Lambda function, ensuring flexibility and automation.

---

## Comparison of Templates

| Feature                | `oidc-template.yaml`        | `multi-org-oidc-template.yaml` |
|------------------------|-----------------------------|---------------------------------|
| Single Owner Support   | ✅                          | ✅                              |
| Multi-Org Support      | ❌                          | ✅                              |
| Wildcard Repo Access   | ❌                          | ✅                              |
| Dynamic Configuration  | ❌                          | ✅                              |

---

## Setup Instructions

### Prerequisites
1. **AWS Account**: Permissions to deploy IAM roles and policies via CloudFormation.
2. **GitHub Repository**: Set up secrets for AWS access (detailed below).

### Step 1: Deploy the CloudFormation Template
1. Use the provided CloudFormation template (`multi-org-oidc-template.yaml`) to deploy:
   - **OIDC Provider**: Establishes trust between GitHub and AWS.
   - **IAM Role**: Allows GitHub Actions to authenticate with AWS via OIDC.

2. Update the `Owners` and `RepositoriesPerOwner` parameters:
   - Specify one or more GitHub organizations or users.
   - Specify repositories or use wildcards as needed.

---

### Step 2: Configure GitHub Secrets
Add the following secrets to your GitHub repository:

| Secret Name         | Value                                  |
|---------------------|----------------------------------------|
| `AWS_ACCOUNT_ROLE`  | The ARN of the IAM role (e.g., `arn:aws:iam::account-id:role/GitHub_Actions_Role`) |
| `AWS_REGION`        | The AWS region where your resources are located |

---

### Step 3: Configure GitHub Actions Workflow
Update your GitHub Actions workflow (`github-action-demo.yaml`) to:
1. Authenticate using OIDC and the role specified in `AWS_ACCOUNT_ROLE`.
2. Perform AWS operations (e.g., list S3 buckets, interact with ECR).

---

### Example Usage

#### Single Owner, Specific Repositories:
```yaml
Owners: pvass24
RepositoriesPerOwner: Resume,k8s-kadence
```

#### Multiple Owners, Mixed Repositories:
```yaml
Owners: pvass24,another-org
RepositoriesPerOwner: "*,k8s-kadence|repo1,repo2"

Owners: pvass24  
RepositoriesPerOwner: *
```

## Benefits of Using OIDC for GitHub Actions

- **No Static Credentials**: Credentials are dynamically generated for each workflow.
- **Automatic Credential Rotation**: AWS issues short-lived tokens, reducing the risk of leaks.
- **Least Privilege Access**: Tailor IAM role policies for specific AWS services.
- **Streamlined Management**: Once set up, no manual rotation or hardcoded keys are needed.

---

## Files in This Repository

| File Name                   | Description                                                 |
|-----------------------------|-------------------------------------------------------------|
| `oidc-template.yaml`        | Basic OIDC template for single-owner setups.               |
| `multi-org-oidc-template.yaml` | Advanced template for multi-org and multi-repo setups.      |
| `github-action-demo.yaml`   | Example GitHub Actions workflow for AWS integration.       |

---

## Conclusion

This advanced OIDC setup provides a robust and flexible solution for integrating GitHub Actions with AWS. By supporting multiple organizations and repositories, this template allows for secure, scalable, and dynamic workflows.

