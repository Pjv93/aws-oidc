# AWS OIDC Authentication for GitHub Actions

This repository provides two CloudFormation templates for implementing secure AWS authentication in GitHub Actions using OIDC. Choose the template that best fits your needs:

- `oidc-template.yaml`: Simple setup for single organization/repository
- `multi-org-oidc-template.yaml`: Advanced setup for multiple organizations and repositories

## Template Comparison

|
 Feature 
|
 Basic Template (
`oidc-template.yaml`
) 
|
 Advanced Template (
`multi-org-oidc-template.yaml`
) 
|
|
---------
|
---------------------------------------
|
---------------------------------------------------
|
|
 Complexity 
|
 Simple, straightforward 
|
 More complex, more flexible 
|
|
 Organizations 
|
 Single organization 
|
 Multiple organizations 
|
|
 Repository Access 
|
 Single repository or organization-wide 
|
 Granular control per organization 
|
|
 Configuration 
|
 Static in template 
|
 Dynamic via parameters 
|
|
 Custom Resources 
|
 No 
|
 Yes (Lambda-powered) 
|
|
 Setup Time 
|
 Quick 
|
 Requires more planning 
|
|
 Best For 
|
 Small projects, single repository 
|
 Enterprise, multi-repository setups 
|

## Deployment Methods

### Method 1: AWS Console Deployment

#### Basic Template Deployment
1. Open the [AWS CloudFormation Console](https://console.aws.amazon.com/cloudformation)
2. Click "Create stack" > "With new resources (standard)"
3. Choose "Upload a template file"
4. Select `oidc-template.yaml`
5. Click "Next"
6. Enter stack details:
   - Stack name: (e.g., `github-oidc-basic`)
   - No parameters required for basic template
7. Click "Next"
8. On the Configure stack options page:
   - Add any tags if desired
   - No additional permissions needed
9. Click "Next"
10. Review the configuration
11. Acknowledge IAM resource creation
12. Click "Create stack"

#### Advanced Template Deployment
1. Open the [AWS CloudFormation Console](https://console.aws.amazon.com/cloudformation)
2. Click "Create stack" > "With new resources (standard)"
3. Choose "Upload a template file"
4. Select `multi-org-oidc-template.yaml`
5. Click "Next"
6. Enter stack details:
   - Stack name: (e.g., `github-oidc-advanced`)
   - Parameters:
     - **Owners**: Enter GitHub organizations/users (e.g., `pvass24,another-org`)
     - **RepositoriesPerOwner**: Enter repository lists (e.g., `Resume,k8s-kadence|repo1,repo2`)
     - **S3BucketName**: Enter your S3 bucket name
7. Click "Next"
8. On the Configure stack options page:
   - Add any tags if desired
   - No additional permissions needed
9. Click "Next"
10. Review the configuration
11. Acknowledge IAM resource creation
12. Click "Create stack"

### Method 2: AWS CLI Deployment

#### Basic Template
```bash
aws cloudformation create-stack \
  --stack-name github-oidc-basic \
  --template-body file://oidc-template.yaml \
  --capabilities CAPABILITY_IAM
```

#### Advanced Template
```bash
aws cloudformation create-stack \
  --stack-name github-oidc-advanced \
  --template-body file://multi-org-oidc-template.yaml \
  --parameters \
    ParameterKey=Owners,ParameterValue="org1,org2" \
    ParameterKey=RepositoriesPerOwner,ParameterValue="repo1,repo2|repo3,repo4" \
    ParameterKey=S3BucketName,ParameterValue="your-bucket-name" \
  --capabilities CAPABILITY_IAM
```

## Template Configuration

### Basic Template (`oidc-template.yaml`)
After deployment, locate the created IAM role in the AWS Console:
1. Navigate to IAM > Roles
2. Find the role created by the stack
3. Edit the trust relationship if needed:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:organization-name/repository-name:*"
        }
      }
    }
  ]
}
```

### Advanced Template (`multi-org-oidc-template.yaml`)
Configuration is handled through stack parameters:

#### Console Configuration
In the CloudFormation console:
1. Select your stack
2. Click "Update"
3. Choose "Use current template"
4. Modify parameters as needed
5. Complete the update process

#### Parameter Formats
- **Owners**: Comma-separated list
  ```
  pvass24,another-org
  ```
- **RepositoriesPerOwner**: Pipe-separated lists
  ```
  Resume,k8s-kadence|repo1,repo2
  ```
  
## GitHub Actions Configuration

### 1. Get Role ARN
After deployment:
1. Go to CloudFormation > Stacks > Your Stack > Outputs
2. Copy the `GitHubActionsRoleArn` value

### 2. Configure GitHub Secrets
In your GitHub repository:
1. Go to Settings > Secrets and variables > Actions
2. Add secrets:
   - `AWS_ROLE_ARN`: Paste the role ARN
   - `AWS_REGION`: Your AWS region

### 3. Update Workflow File
```yaml
jobs:
  aws-deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: ${{ secrets.AWS_REGION }}
```

## Post-Deployment Verification

### Console Verification
1. Navigate to CloudFormation > Stacks
2. Check stack status (should be `CREATE_COMPLETE`)
3. Review the Resources tab for created components
4. Verify Outputs tab for role ARN

### CLI Verification
```bash
# Check stack status
aws cloudformation describe-stacks --stack-name your-stack-name

# List stack resources
aws cloudformation list-stack-resources --stack-name your-stack-name

# Get stack outputs
aws cloudformation describe-stacks --stack-name your-stack-name --query 'Stacks[0].Outputs'
```

## Troubleshooting

### Console-Related Issues
1. **Stack Creation Fails**:
   - Check CloudFormation Events tab for error messages
   - Verify IAM permissions
   - Ensure parameter formats are correct

2. **Role Access Issues**:
   - Review IAM role in console
   - Check trust relationship configuration
   - Verify OIDC provider setup

### Common Error Messages
- `NoSuchBucket`: Verify S3 bucket exists and is accessible
- `InvalidParameterValue`: Check parameter formatting
- `AccessDenied`: Review IAM permissions

## Additional Resources

- [AWS CloudFormation Console Guide](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console.html)
- [GitHub OIDC Documentation](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
- [AWS IAM OIDC Documentation](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc.html)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
