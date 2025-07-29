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

locals {
  name = "custom-user-data"
  tags = {
    Environment = "test"
    Project     = "ec2-server-example"
  }
}

module "vpc" {
  source  = "cloudbuildlab/vpc/aws"
  version = "~> 1.0"

  vpc_name = local.name
  vpc_cidr = "10.2.0.0/16"

  availability_zones   = ["ap-southeast-2a", "ap-southeast-2b"]
  public_subnet_cidrs  = ["10.2.10.0/24", "10.2.11.0/24"]
  private_subnet_cidrs = ["10.2.20.0/24", "10.2.21.0/24"]

  tags = local.tags
}

# Additional security group rule for HTTP access
resource "aws_security_group_rule" "http_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.custom_server.security_group_id
  description       = "HTTP access for webserver"
}

module "custom_server" {
  source = "../../"

  name          = local.name
  instance_tags = local.tags

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnet_ids[0]

  instance_type    = "t3.micro"
  assign_public_ip = true

  enable_ssm = true

  user_data = <<-EOF
#!/bin/bash
exec > >(tee /var/log/user-data.log) 2>&1

echo "Starting user data script..."

# Update system
yum update -y

# Install nginx using amazon-linux-extras
amazon-linux-extras install nginx1 -y

# Create a simple test page
cat > /usr/share/nginx/html/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head>
    <title>Custom User Data Test</title>
</head>
<body>
    <h1>Hello from Custom User Data!</h1>
    <p>This page was created by the user data script.</p>
    <p>Timestamp: $(date)</p>
</body>
</html>
HTML

# Start and enable nginx
systemctl start nginx
systemctl enable nginx

echo "User data script completed successfully!"
EOF
}

output "instance_id" {
  description = "ID of the EC2 instance"
  value       = module.custom_server.instance_id
}

output "public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = module.custom_server.public_ip
}

output "ssm_instance_url" {
  description = "SSM Console Session URL for the instance"
  value       = module.custom_server.ssm_instance_url
}
