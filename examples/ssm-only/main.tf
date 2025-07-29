# SSM-Only Access Example
#
# This example demonstrates how to create an EC2 instance with SSM access only
# using the terraform-aws-ec2-server module.
#
# Features:
# - SSM access enabled (no SSH key required)
# - No webserver role (basic instance)
# - No public IP assignment (private only)
# - No CloudWatch logs
# - IAM role with SSM permissions
# - Secure access via AWS Systems Manager
#
# Use case: Development servers, bastion hosts, or when you need secure access
# to instances without exposing them to the internet or requiring SSH keys.

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
  name = "ssm-only-server"
  tags = {
    Environment = "dev"
    Project     = "ssm-example"
    Type        = "ssm-only"
    Access      = "ssm"
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

# SSM-only server for secure access
module "ssm_server" {
  source = "../../"

  # Required variables - using VPC module outputs
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  # Name for resource identification
  name = local.name

  # Instance configuration
  instance_type = "t3.micro"
  # Note: assign_public_ip = false (default)

  # Access configuration
  enable_ssm = true
  # Note: No webserver role, no CloudWatch logs

  # Resource tagging
  instance_tags = local.tags
}

# Outputs
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.ssm_server.instance_id
}

output "private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = module.ssm_server.private_ip
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = module.ssm_server.security_group_id
}

output "ssm_instance_url" {
  description = "SSM Console Session URL for secure access"
  value       = module.ssm_server.ssm_instance_url
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "The ID of the subnet where the instance is deployed"
  value       = module.vpc.private_subnet_ids[0]
}
