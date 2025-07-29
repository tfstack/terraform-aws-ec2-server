# Apache Webserver Example
#
# This example demonstrates how to create an EC2 instance with Apache webserver
# using the terraform-aws-ec2-server module.
#
# Features:
# - Apache webserver automatically installed and configured
# - SSM access enabled (no SSH key required)
# - Public IP assigned for web access
# - Custom index.html page created
# - Security group allows HTTP traffic (port 80)
# - IAM role with SSM permissions
# - Larger instance type for better performance
#
# Use case: Web applications, development servers, or when you need an Apache web server
# with secure access via SSM.

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
  name = "apache-webserver"
  tags = {
    Environment = "staging"
    Project     = "webserver-example"
    Type        = "webserver"
    Webserver   = "apache"
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

# Apache webserver with SSM access
module "apache_webserver" {
  source = "../../"

  # Required variables - using VPC module outputs
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]

  # Name for resource identification
  name = local.name

  # Webserver configuration
  role           = "webserver"
  webserver_type = "apache"

  # Instance configuration
  instance_type    = "t3.small"
  assign_public_ip = true

  # Access configuration
  enable_ssm = true
  # Note: CloudWatch logs disabled for this example

  # Resource tagging
  instance_tags = local.tags
}

# Outputs
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.apache_webserver.instance_id
}

output "public_ip" {
  description = "The public IP address for web access"
  value       = module.apache_webserver.public_ip
}

output "private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = module.apache_webserver.private_ip
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = module.apache_webserver.security_group_id
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "The ID of the subnet where the instance is deployed"
  value       = module.vpc.public_subnet_ids[0]
}
