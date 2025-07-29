# Apache Webserver Example

This example demonstrates how to create an EC2 instance with Apache webserver using the `terraform-aws-ec2-server` module.

## Features

- Apache webserver automatically installed and configured
- Public IP assigned for web access
- Custom index.html page created
- Security group allows HTTP traffic (port 80)
- Larger instance type for better performance
- **Creates complete VPC infrastructure** (VPC, subnets, route tables, etc.)

## Use Case

Web applications, development servers, or when you need an Apache web server.

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
- `vpc_id`: The ID of the created VPC
- `subnet_id`: The ID of the subnet where the instance is deployed

## Access

### Web Access

- Access the webserver at `http://<public_ip>`
- The server will display a custom index.html page

## Differences from Nginx Example

- Uses Apache instead of Nginx
- Larger instance type (t3.small vs t3.micro)
- Different document root (`/var/www/html` vs `/usr/share/nginx/html`)
