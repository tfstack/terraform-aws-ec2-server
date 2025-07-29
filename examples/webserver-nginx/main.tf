# Nginx Webserver Example
#
# This example demonstrates how to create an EC2 instance with nginx webserver
# using the terraform-aws-ec2-server module.
#
# Features:
# - Nginx webserver automatically installed and configured
# - SSM access enabled (no SSH key required)
# - Public IP assigned for web access
# - CloudWatch logs enabled for monitoring
# - Custom index.html page created
# - Security group allows HTTP traffic (port 80)
# - IAM role with SSM and CloudWatch permissions
#
# Use case: Web applications, development servers, or when you need a web server
# with monitoring and secure access via SSM.

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
  name = "nginx-webserver"
  tags = {
    Environment = "dev"
    Project     = "webserver-example"
    Type        = "webserver"
    Webserver   = "nginx"
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

# Nginx webserver with full features enabled
module "nginx_webserver" {
  source = "../../"

  # Required variables - using VPC module outputs
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]

  # Name for resource identification
  name = local.name

  # Webserver configuration
  role           = "webserver"
  webserver_type = "nginx"

  # Instance configuration
  instance_type    = "t3.micro"
  assign_public_ip = true

  # Access and monitoring
  enable_ssm     = true
  enable_cw_logs = true

  # Resource tagging
  instance_tags = local.tags
}

# Outputs
output "instance_id" {
  description = "The ID of the EC2 instance"
  value       = module.nginx_webserver.instance_id
}

output "public_ip" {
  description = "The public IP address for web access"
  value       = module.nginx_webserver.public_ip
}

output "private_ip" {
  description = "The private IP address of the EC2 instance"
  value       = module.nginx_webserver.private_ip
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = module.nginx_webserver.security_group_id
}

output "ssm_instance_url" {
  description = "SSM Console Session URL for secure access"
  value       = module.nginx_webserver.ssm_instance_url
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "subnet_id" {
  description = "The ID of the subnet where the instance is deployed"
  value       = module.vpc.public_subnet_ids[0]
}
