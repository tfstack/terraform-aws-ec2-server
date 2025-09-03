# EBS Volumes Example
#
# This example demonstrates how to create EC2 instances with EBS volumes
# using the terraform-aws-ec2-server module.
#
# Features:
# - Single EBS volume configuration
# - Multiple EBS volumes configuration
# - Automatic volume mounting via user data
# - SSM access enabled for management
# - Private instances with secure access
# - Custom volume types and encryption
#
# Use case: Applications requiring persistent storage, databases, log storage,
# or any workload that needs additional disk space beyond the root volume.

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

# Locals for consistent naming and tagging
locals {
  base_name = "ebs-test"
  tags = {
    Environment = "test"
    Project     = "terraform-aws-ec2-server"
    Example     = "ebs-volumes"
  }
}

# VPC and networking infrastructure
module "vpc" {
  source = "cloudbuildlab/vpc/aws"

  vpc_name = "${local.base_name}-vpc"
  vpc_cidr = "10.3.0.0/16"

  availability_zones   = ["ap-southeast-2a", "ap-southeast-2b"]
  public_subnet_cidrs  = ["10.3.10.0/24", "10.3.11.0/24"]
  private_subnet_cidrs = ["10.3.20.0/24", "10.3.21.0/24"]

  tags = local.tags
}

# Single EBS volume server
module "single_ebs_server" {
  source = "../../"

  # Required variables - using VPC module outputs
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[0]

  # Name for resource identification
  name = "${local.base_name}-single"

  # Instance configuration
  instance_type = "t3.micro"
  # Note: assign_public_ip = false (default)

  # Access configuration
  enable_ssm = true
  # Note: No webserver role, no CloudWatch logs

  # Single EBS volume configuration
  ebs_volume_size = 10
  ebs_volume_type = "gp3"
  ebs_device_name = "/dev/xvdf"

  # Custom user data for volume mounting
  user_data = templatefile("${path.module}/user_data.sh", {
    ebs_device = "/dev/xvdf"
    mount_path = "/mnt"
    hostname   = "${local.base_name}-single"
  })

  # Resource tagging
  instance_tags = local.tags
}

# Multiple EBS volumes server
module "multiple_ebs_server" {
  source = "../../"

  # Required variables - using VPC module outputs
  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.private_subnet_ids[1]

  # Name for resource identification
  name = "${local.base_name}-multiple"

  # Instance configuration
  instance_type = "t3.small"
  # Note: assign_public_ip = false (default)

  # Access configuration
  enable_ssm = true
  # Note: No webserver role, no CloudWatch logs

  # Multiple EBS volumes configuration
  ebs_volumes = [
    {
      device_name = "/dev/xvdf"
      volume_size = 10
      volume_type = "gp3"
      encrypted   = true
      tags        = { Purpose = "content" }
    },
    {
      device_name = "/dev/xvdg"
      volume_size = 5
      volume_type = "gp3"
      encrypted   = true
      tags        = { Purpose = "logs" }
    }
  ]

  # Custom user data for volume mounting
  user_data = templatefile("${path.module}/user_data.sh", {
    ebs_device = "/dev/xvdf"
    mount_path = "/mnt"
    hostname   = "${local.base_name}-multiple"
  })

  # Resource tagging
  instance_tags = local.tags
}

# Outputs
output "single_instance_id" {
  description = "The ID of the single EBS volume EC2 instance"
  value       = module.single_ebs_server.instance_id
}

output "single_private_ip" {
  description = "The private IP address of the single EBS volume instance"
  value       = module.single_ebs_server.private_ip
}

output "single_ebs_volume_ids" {
  description = "List of EBS volume IDs for the single volume instance"
  value       = module.single_ebs_server.ebs_volume_ids
}

output "multiple_instance_id" {
  description = "The ID of the multiple EBS volumes EC2 instance"
  value       = module.multiple_ebs_server.instance_id
}

output "multiple_private_ip" {
  description = "The private IP address of the multiple EBS volumes instance"
  value       = module.multiple_ebs_server.private_ip
}

output "multiple_ebs_volume_ids" {
  description = "List of EBS volume IDs for the multiple volumes instance"
  value       = module.multiple_ebs_server.ebs_volume_ids
}

output "multiple_ebs_volume_attachments" {
  description = "Map of device names to volume IDs for the multiple volumes instance"
  value       = module.multiple_ebs_server.ebs_volume_attachments
}

output "ssm_instance_urls" {
  description = "SSM Console Session URLs for secure access"
  value = {
    single   = module.single_ebs_server.ssm_instance_url
    multiple = module.multiple_ebs_server.ssm_instance_url
  }
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "subnet_ids" {
  description = "The IDs of the subnets where instances are deployed"
  value = {
    single   = module.vpc.private_subnet_ids[0]
    multiple = module.vpc.private_subnet_ids[1]
  }
}
