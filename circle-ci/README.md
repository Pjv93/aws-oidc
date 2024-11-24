# CircleCI OIDC Authentication with AWS

This repository provides the necessary CloudFormation template and CircleCI pipeline configuration to securely authenticate CircleCI pipelines with AWS using OpenID Connect (OIDC). This setup eliminates the need for long-lived AWS credentials and leverages dynamic, short-lived tokens for secure, automated access.

---

## Why Use This Setup?

Traditional CI/CD pipeline authentication often relies on static AWS access keys, which have drawbacks:
- **Security Risks**: Hardcoded credentials are prone to leakage.
- **Complex Management**: Keys require rotation and secure storage.
- **Static Tokens**: Lack of dynamic automation.

### Benefits of OIDC Authentication:
1. **Dynamic Authentication**: Temporary credentials are issued per pipeline run.
2. **Improved Security**: Leverages AWS's temporary token mechanism for enhanced security.
3. **Granular Access Control**: Permissions are dynamically scoped to the pipeline needs.
4. **Streamlined Management**: No need for manual key rotation.

---

## Features

1. **Dynamic Trust Policies**:
   - Lambda function dynamically constructs IAM trust policies.
   - Flexible support for multiple projects, branches, and users.

2. **Granular Access Control**:
   - Specify which projects, branches, and users can access AWS resources.

3. **Seamless AWS Integration**:
   - Directly interact with AWS services like S3, EKS, and CloudFormation.

4. **Extensible Configuration**:
   - Add or modify projects and branches easily in the CloudFormation template.

---

## Files in This Repository

| File Name                    | Description                                                                 |
|------------------------------|-----------------------------------------------------------------------------|
| `circle-ci-oidc-template.yaml` | CloudFormation template for setting up OIDC trust with CircleCI.            |
| `.circleci/config.yml`        | Example CircleCI pipeline for verifying and using AWS access.               |

---

## Prerequisites

### AWS Account:
1. IAM permissions to deploy CloudFormation stacks.
2. An S3 bucket or other AWS resources that CircleCI pipelines will access.

### CircleCI Organization:
1. **Organization ID**: Found under **Organization Settings > Organization ID** in CircleCI.
2. **Projects enabled for OIDC integration**:
   - Navigate to **Project Settings > Advanced** and enable **"Pass secrets to builds from forked pull requests"** (if needed).

### Environment Variables:
To add the required environment variables for CircleCI:
1. Go to your **CircleCI Project**.
2. Navigate to **Project Settings > Environment Variables**.
3. Add the following variables:
   - **`AWS_REGION`**: The AWS region where your resources are located (e.g., `us-east-1`).
   - **`ROLE_ARN`**: The ARN of the IAM role created by the CloudFormation template.

---

## Step 1: Deploy the CloudFormation Template

### Suggested Method: Use the AWS Management Console
1. Log in to the AWS Management Console.
2. Navigate to the **CloudFormation** service.
3. Click **Create stack** and select **"With new resources (standard)"**.
4. Upload the `circle-ci-oidc-template.yaml` file.
5. Enter the required parameters:
   - **CircleCIOrgID**: Your CircleCI Organization ID (e.g., `12345678-90ab-cdef-1234-567890abcdef`).
   - **ProjectBranches**: Pipe-separated list of projects and their associated branches.
     - Format: `"project1:main,develop|project2:feature-xyz|*:*"`
   - **UserID**: CircleCI User ID (optional). Use `*` to allow all users.
   - **S3BucketName**: Name of the AWS S3 bucket to access.
   - **IAMRoleName**: Name of the IAM role to create (default: `CircleCI_OIDC_Role`).
6. Follow the prompts and deploy the stack.

---

## Step 2: Configure the CircleCI Pipeline

Use the `.circleci/config.yml` provided in this repository to configure your CircleCI pipeline.

### Explanation of the Pipeline

1. **Version**: `2.1` is used to specify the CircleCI configuration version.
2. **Orb**: The `aws-cli` orb simplifies AWS CLI integration with reusable commands.
3. **Environment Variables**:
   - `$AWS_REGION` and `$ROLE_ARN` are loaded from the project environment variables.

### Example Pipeline (`.circleci/config.yml`)

```yaml
version: '2.1'

# Import the AWS CLI Orb, which provides reusable AWS CLI commands and configurations.
orbs:
  aws-cli: circleci/aws-cli@5.1

jobs:
  aws-cli-example:
    # Use the default executor provided by the AWS CLI orb.
    executor: aws-cli/default
    steps:
      # Step 1: Check out the project repository.
      - checkout

      # Step 2: Set up the AWS CLI with OIDC authentication.
      # This uses the AWS CLI orb's setup command to:
      # - Assume the IAM role specified in $ROLE_ARN.
      # - Use the $AWS_REGION for AWS operations.
      # - Create a profile named 'OIDC-PROFILE' for AWS CLI commands.
      - aws-cli/setup:
          profile_name: OIDC-PROFILE  # Name of the AWS CLI profile to use for commands.
          role_arn: $ROLE_ARN         # IAM role to assume for OIDC authentication.
          region: $AWS_REGION         # AWS region for commands.
          role_session_name: example-session  # Session name for the assumed role.

      # Step 3: Verify AWS role assumption.
      - run:
          name: Verify AWS Role Assumption
          command: aws sts get-caller-identity --profile OIDC-PROFILE

      # Step 4: List the contents of the specified S3 bucket.
      - run:
          name: List Contents of S3 Bucket
          command: aws s3 ls s3://my-circleci-bucket --profile OIDC-PROFILE

workflows:
  # Define the workflow, which runs the 'aws-cli-example' job.
  aws-cli:
    jobs:
      - aws-cli-example:
          context: aws  # Use the 'aws' context to load environment variables like $ROLE_ARN and $AWS_REGION.
```

## Outputs

| Output Name      | Description                                          |
|------------------|------------------------------------------------------|
| **IAMRoleArn**   | The ARN of the IAM role for CircleCI OIDC pipelines. |
| **OIDCProviderArn** | The ARN of the CircleCI OIDC Provider.            |

---
## Examples

## Examples for `ProjectBranches` Parameter Configuration

The `ProjectBranches` parameter in the CloudFormation template allows you to define the projects and their corresponding branches for which the IAM role will be accessible. Below are some example configurations to help you set this up.

### Example 1: All Projects and All Branches
ProjectBranches: "*:*"
- **Explanation**: 
  - Allows access to all projects and all branches within the specified CircleCI organization.

---

### Example 2: Specific Projects with Specific Branches
ProjectBranches: "project1:main,develop|project2:feature-xyz"

- **Explanation**:
  - For `project1`, access is restricted to the `main` and `develop` branches.
  - For `project2`, access is restricted to the `feature-xyz` branch.

---

### Example 3: A Combination of Wildcard and Specific Branches
ProjectBranches: "project1:*|project2:main"

- **Explanation**:
  - For `project1`, all branches are allowed.
  - For `project2`, only the `main` branch is allowed.

---

### Example 4: Restrict Access to a Single Project and Branch
ProjectBranches: "my-project:main"

- **Explanation**:
  - Only the `main` branch of `my-project` is allowed access.

---

### Example 5: Mixed Wildcards for Projects and Branches
ProjectBranches: "\n*:main,develop|project2:*\n"

- **Explanation**:
  - All projects have access to the `main` and `develop` branches.
  - For `project2`, all branches are accessible.

---

## Support

For any issues, questions, or suggestions, please open an issue in this repository. Contributions are always welcome!
