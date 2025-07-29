# Basic EC2 Server Example
#
# This example demonstrates the minimal configuration required to create an EC2 instance
# using the terraform-aws-ec2-server module.
#
# Features:
# - Minimal configuration with only required variables
# - No webserver role (basic instance only)
# - No SSM access (SSH key required for access)
# - No public IP assignment
# - No CloudWatch logs
# - Default t3.micro instance type
# - Amazon Linux 2 AMI
#
# Use case: Simple development server, testing, or when you need a basic EC2 instance
# without additional features.

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

# Locals for consistent naming and tagging
locals {
  name = "basic"
  tags = {
    Environment = "dev"
    Project     = "basic-example"
    Type        = "basic-server"
  }
}

# VPC and networking infrastructure
module "vpc" {
  source = "cloudbuildlab/vpc/aws"

  vpc_name = local.name
  vpc_cidr = "10.2.0.0/16"

  availability_zones   = ["ap-southeast-2a", "ap-southeast-2b"]
  public_subnet_cidrs  = ["10.2.10.0/24", "10.2.11.0/24"]
  private_subnet_cidrs = ["10.2.20.0/24", "10.2.21.0/24"]

  tags = local.tags
}

# Basic EC2 server with minimal configuration
module "basic_server" {
  source = "../../"

  # Required variables - using VPC module outputs
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  # Name for resource identification
  name = local.name

  # Optional: Override default instance type
  instance_type = "t3.micro"

  # Optional: Add tags for resource management
  instance_tags = local.tags
}

# Outputs
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.basic_server.instance_id
}

output "private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = module.basic_server.private_ip
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = module.basic_server.security_group_id
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "The ID of the subnet where the instance is deployed"
  value       = module.vpc.private_subnet_ids[0]
}
