# SSM-Only Access Example

This example demonstrates how to create an EC2 instance with SSM access only using the `terraform-aws-ec2-server` module.

## Features

- SSM access enabled (no SSH key required)
- No webserver role (basic instance)
- No public IP assignment (private only)
- No CloudWatch logs
- IAM role with SSM permissions
- Secure access via AWS Systems Manager
- **Creates complete VPC infrastructure** (VPC, subnets, route tables, etc.)

## Use Case

Development servers, bastion hosts, or when you need secure access to instances without exposing them to the internet or requiring SSH keys.

## Usage

1. The example creates its own VPC infrastructure, so no manual VPC/subnet configuration is required
2. Run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

## Infrastructure Created

This example creates:

- VPC with CIDR `10.2.0.0/16`
- 2 public subnets in `ap-southeast-2a` and `ap-southeast-2b`
- 2 private subnets in `ap-southeast-2a` and `ap-southeast-2b`
- Internet Gateway and NAT Gateway
- Route tables for public and private subnets
- EC2 instance in the first private subnet (for security)

## Outputs

- `instance_id`: The ID of the EC2 instance
- `private_ip`: The private IP address of the EC2 instance
- `security_group_id`: The ID of the security group
- `ssm_instance_url`: SSM Console Session URL for secure access
- `vpc_id`: The ID of the created VPC
- `subnet_id`: The ID of the subnet where the instance is deployed

## Access

### SSM Console

- Use the SSM Console Session URL from the outputs
- Click the URL to open a browser-based terminal session

### AWS CLI

```bash
aws ssm start-session --target <instance_id>
```

### AWS Console

- Navigate to EC2 > Instances
- Select your instance
- Click "Connect" > "Session Manager" > "Connect"

## Security Benefits

- No SSH keys required
- No public IP exposure
- IAM-based access control
- Session logging and auditing
- Encrypted communication
- Instance deployed in private subnet

## Prerequisites

- AWS Systems Manager agent installed (handled by the module)
- Proper IAM permissions for SSM
- VPC endpoints for SSM (recommended for private subnets)
