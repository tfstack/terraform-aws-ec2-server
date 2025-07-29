# Nginx Webserver Example

This example demonstrates how to create an EC2 instance with nginx webserver using the `terraform-aws-ec2-server` module.

## Features

- Nginx webserver automatically installed and configured
- SSM access enabled (no SSH key required)
- Public IP assigned for web access
- CloudWatch logs enabled for monitoring
- Custom index.html page created
- Security group allows HTTP traffic (port 80)
- IAM role with SSM and CloudWatch permissions
- **Creates complete VPC infrastructure** (VPC, subnets, route tables, etc.)

## Use Case

Web applications, development servers, or when you need a web server with monitoring and secure access via SSM.

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
- EC2 instance in the first public subnet (for web access)

## Outputs

- `instance_id`: The ID of the EC2 instance
- `public_ip`: The public IP address for web access
- `private_ip`: The private IP address of the EC2 instance
- `security_group_id`: The ID of the security group
- `ssm_instance_url`: SSM Console Session URL for secure access
- `vpc_id`: The ID of the created VPC
- `subnet_id`: The ID of the subnet where the instance is deployed

## Access

### Web Access

- Access the webserver at `http://<public_ip>`
- The server will display a custom index.html page

### Server Access

- Use the SSM Console Session URL from the outputs
- Or use AWS CLI: `aws ssm start-session --target <instance_id>`

## Monitoring

- CloudWatch logs are automatically configured
- Logs are available in CloudWatch Logs under `/aws/ec2/instance/<instance_id>/`
- System metrics are also collected
