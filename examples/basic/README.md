# Basic EC2 Server Example

This example demonstrates the minimal configuration required to create an EC2 instance using the `terraform-aws-ec2-server` module.

## Features

- Minimal configuration with only required variables
- No webserver role (basic instance only)
- No SSM access (SSH key required for access)
- No public IP assignment
- No CloudWatch logs
- Default t3.micro instance type
- Amazon Linux 2 AMI
- **Creates complete VPC infrastructure** (VPC, subnets, route tables, etc.)

## Use Case

Simple development server, testing, or when you need a basic EC2 instance without additional features.

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
- EC2 instance in the first private subnet

## Outputs

- `instance_id`: The ID of the EC2 instance
- `private_ip`: The private IP address of the EC2 instance
- `security_group_id`: The ID of the security group
- `vpc_id`: The ID of the created VPC
- `subnet_id`: The ID of the subnet where the instance is deployed

## Access

Since this example doesn't enable SSM, you'll need to:

- Use an SSH key pair for access
- Ensure your security group allows SSH traffic (port 22)
- Access via the private IP address
- Consider using a bastion host or VPN for secure access to the private subnet
