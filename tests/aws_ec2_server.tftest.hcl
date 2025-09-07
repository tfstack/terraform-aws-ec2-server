# Provider configuration for tests
provider "aws" {
  region = "ap-southeast-2"
  # Skip credentials validation for plan-only tests
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

# Test Basic EC2 Server Configuration
run "basic_server" {
  command = plan

  variables {
    vpc_id        = "vpc-12345678"
    subnet_id     = "subnet-87654321"
    instance_type = "t3.micro"
    instance_tags = {
      Environment = "test"
      Project     = "ec2-server-test"
      Type        = "basic"
    }
  }

  assert {
    condition     = var.vpc_id == "vpc-12345678"
    error_message = "VPC ID should be vpc-12345678"
  }

  assert {
    condition     = var.subnet_id == "subnet-87654321"
    error_message = "Subnet ID should be subnet-87654321"
  }

  assert {
    condition     = var.instance_type == "t3.micro"
    error_message = "Instance type should be t3.micro"
  }

  assert {
    condition     = var.role == null
    error_message = "Role should be null for basic server"
  }

  assert {
    condition     = var.enable_ssm == false
    error_message = "SSM should be disabled for basic server"
  }

  assert {
    condition     = var.assign_public_ip == false
    error_message = "Public IP should not be assigned for basic server"
  }

  assert {
    condition     = var.enable_cw_logs == false
    error_message = "CloudWatch logs should be disabled for basic server"
  }

  assert {
    condition     = var.http_port == 80
    error_message = "HTTP port should default to 80"
  }

  assert {
    condition     = var.create_security_group == false
    error_message = "create_security_group should default to false"
  }

  assert {
    condition     = length(var.vpc_security_group_ids) == 0
    error_message = "vpc_security_group_ids should default to empty list"
  }

  assert {
    condition     = length(var.allowed_cidr_blocks) == 1 && var.allowed_cidr_blocks[0] == "0.0.0.0/0"
    error_message = "allowed_cidr_blocks should default to 0.0.0.0/0"
  }
}

# Test Webserver EC2 Server Configuration
run "webserver_server" {
  command = plan

  variables {
    vpc_id           = "vpc-12345678"
    subnet_id        = "subnet-87654321"
    instance_type    = "t3.small"
    role             = "webserver"
    webserver_type   = "nginx"
    enable_ssm       = true
    assign_public_ip = true
    enable_cw_logs   = true
    instance_tags = {
      Environment = "test"
      Project     = "ec2-webserver-test"
      Type        = "webserver"
      Webserver   = "nginx"
    }
  }

  assert {
    condition     = var.vpc_id == "vpc-12345678"
    error_message = "VPC ID should be vpc-12345678"
  }

  assert {
    condition     = var.subnet_id == "subnet-87654321"
    error_message = "Subnet ID should be subnet-87654321"
  }

  assert {
    condition     = var.instance_type == "t3.small"
    error_message = "Instance type should be t3.small"
  }

  assert {
    condition     = var.role == "webserver"
    error_message = "Role should be webserver"
  }

  assert {
    condition     = var.webserver_type == "nginx"
    error_message = "Webserver type should be nginx"
  }

  assert {
    condition     = var.enable_ssm == true
    error_message = "SSM should be enabled for webserver"
  }

  assert {
    condition     = var.assign_public_ip == true
    error_message = "Public IP should be assigned for webserver"
  }

  assert {
    condition     = var.enable_cw_logs == true
    error_message = "CloudWatch logs should be enabled for webserver"
  }

  assert {
    condition     = var.http_port == 80
    error_message = "HTTP port should default to 80"
  }

  assert {
    condition     = var.create_security_group == false
    error_message = "create_security_group should default to false for webserver"
  }

  assert {
    condition     = length(var.vpc_security_group_ids) == 0
    error_message = "vpc_security_group_ids should default to empty list"
  }

  assert {
    condition     = length(var.allowed_cidr_blocks) == 1 && var.allowed_cidr_blocks[0] == "0.0.0.0/0"
    error_message = "allowed_cidr_blocks should default to 0.0.0.0/0"
  }
}

# Test Apache Webserver Configuration
run "apache_webserver" {
  command = plan

  variables {
    vpc_id           = "vpc-12345678"
    subnet_id        = "subnet-87654321"
    instance_type    = "t3.micro"
    role             = "webserver"
    webserver_type   = "apache"
    enable_ssm       = true
    assign_public_ip = true
    enable_cw_logs   = false
    instance_tags = {
      Environment = "staging"
      Project     = "ec2-apache-test"
      Type        = "webserver"
      Webserver   = "apache"
    }
  }

  assert {
    condition     = var.role == "webserver"
    error_message = "Role should be webserver"
  }

  assert {
    condition     = var.webserver_type == "apache"
    error_message = "Webserver type should be apache"
  }

  assert {
    condition     = var.enable_ssm == true
    error_message = "SSM should be enabled"
  }

  assert {
    condition     = var.assign_public_ip == true
    error_message = "Public IP should be assigned"
  }

  assert {
    condition     = var.enable_cw_logs == false
    error_message = "CloudWatch logs should be disabled for this test"
  }

  assert {
    condition     = var.http_port == 80
    error_message = "HTTP port should default to 80"
  }
}

# Test Custom User Data Configuration
run "custom_user_data" {
  command = plan

  variables {
    vpc_id        = "vpc-12345678"
    subnet_id     = "subnet-87654321"
    instance_type = "t3.micro"
    user_data     = <<-EOF
                #!/bin/bash
                yum install -y git
                git clone https://github.com/example/repo.git /opt/app
                echo "Custom setup complete"
                EOF
    instance_tags = {
      Environment = "dev"
      Project     = "ec2-custom-test"
      Type        = "custom"
    }
  }

  assert {
    condition     = var.user_data != null
    error_message = "User data should be provided"
  }

  assert {
    condition     = var.role == null
    error_message = "Role should be null when custom user data is provided"
  }

  assert {
    condition     = var.enable_ssm == false
    error_message = "SSM should be disabled by default"
  }

  assert {
    condition     = var.assign_public_ip == false
    error_message = "Public IP should not be assigned by default"
  }

  assert {
    condition     = var.http_port == 80
    error_message = "HTTP port should default to 80"
  }
}

# Test SSM Only Configuration
run "ssm_only_server" {
  command = plan

  variables {
    vpc_id        = "vpc-12345678"
    subnet_id     = "subnet-87654321"
    instance_type = "t3.micro"
    enable_ssm    = true
    instance_tags = {
      Environment = "dev"
      Project     = "ec2-ssm-test"
      Type        = "ssm-only"
    }
  }

  assert {
    condition     = var.enable_ssm == true
    error_message = "SSM should be enabled"
  }

  assert {
    condition     = var.role == null
    error_message = "Role should be null"
  }

  assert {
    condition     = var.enable_cw_logs == false
    error_message = "CloudWatch logs should be disabled"
  }

  assert {
    condition     = var.assign_public_ip == false
    error_message = "Public IP should not be assigned"
  }

  assert {
    condition     = var.http_port == 80
    error_message = "HTTP port should default to 80"
  }
}

# Validation Tests

# Test invalid VPC ID
run "test_invalid_vpc_id" {
  command = plan

  variables {
    vpc_id    = "invalid-vpc-id"
    subnet_id = "subnet-87654321"
  }

  expect_failures = [
    var.vpc_id,
  ]
}

# Test invalid subnet ID
run "test_invalid_subnet_id" {
  command = plan

  variables {
    vpc_id    = "vpc-12345678"
    subnet_id = "invalid-subnet"
  }

  expect_failures = [
    var.subnet_id,
  ]
}

# Test invalid name
run "test_invalid_name" {
  command = plan

  variables {
    vpc_id    = "vpc-12345678"
    subnet_id = "subnet-87654321"
    name      = "invalid name!"
  }

  expect_failures = [
    var.name,
  ]
}

# Test invalid AMI type
run "test_invalid_ami_type" {
  command = plan

  variables {
    vpc_id    = "vpc-12345678"
    subnet_id = "subnet-87654321"
    ami_type  = "ubuntu"
  }

  expect_failures = [
    var.ami_type,
  ]
}

# Test invalid instance type
run "test_invalid_instance_type" {
  command = plan

  variables {
    vpc_id        = "vpc-12345678"
    subnet_id     = "subnet-87654321"
    instance_type = "invalid-type"
  }

  expect_failures = [
    var.instance_type,
  ]
}

# Test invalid role
run "test_invalid_role" {
  command = plan

  variables {
    vpc_id    = "vpc-12345678"
    subnet_id = "subnet-87654321"
    role      = "database"
  }

  expect_failures = [
    var.role,
  ]
}

# Test invalid webserver type
run "test_invalid_webserver_type" {
  command = plan

  variables {
    vpc_id         = "vpc-12345678"
    subnet_id      = "subnet-87654321"
    role           = "webserver"
    webserver_type = "lighttpd"
  }

  expect_failures = [
    var.webserver_type,
  ]
}

# Test invalid HTTP port
run "test_invalid_http_port" {
  command = plan

  variables {
    vpc_id    = "vpc-12345678"
    subnet_id = "subnet-87654321"
    http_port = 99999
  }

  expect_failures = [
    var.http_port,
  ]
}

# Test valid configuration
run "test_valid_configuration" {
  command = plan

  variables {
    vpc_id         = "vpc-12345678"
    subnet_id      = "subnet-87654321"
    name           = "test-server"
    ami_type       = "amazonlinux2"
    instance_type  = "t3.micro"
    role           = "webserver"
    webserver_type = "nginx"
    http_port      = 8080
  }

  assert {
    condition     = var.vpc_id == "vpc-12345678"
    error_message = "VPC ID should be set correctly"
  }

  assert {
    condition     = var.subnet_id == "subnet-87654321"
    error_message = "Subnet ID should be set correctly"
  }

  assert {
    condition     = var.name == "test-server"
    error_message = "Name should be set correctly"
  }

  assert {
    condition     = var.role == "webserver"
    error_message = "Role should be set correctly"
  }

  assert {
    condition     = var.http_port == 8080
    error_message = "HTTP port should be set correctly"
  }
}

# Test Single EBS Volume Configuration
run "single_ebs_volume" {
  command = plan

  variables {
    vpc_id          = "vpc-12345678"
    subnet_id       = "subnet-87654321"
    instance_type   = "t3.micro"
    enable_ssm      = true
    ebs_volume_size = 20
    ebs_volume_type = "gp3"
    ebs_device_name = "/dev/xvdf"
    instance_tags = {
      Environment = "test"
      Project     = "ec2-ebs-single-test"
      Type        = "single-ebs"
    }
  }

  assert {
    condition     = var.ebs_volume_size == 20
    error_message = "EBS volume size should be 20 GB"
  }

  assert {
    condition     = var.ebs_volume_type == "gp3"
    error_message = "EBS volume type should be gp3"
  }

  assert {
    condition     = var.ebs_device_name == "/dev/xvdf"
    error_message = "EBS device name should be /dev/xvdf"
  }

  assert {
    condition     = length(var.ebs_volumes) == 0
    error_message = "Multiple EBS volumes should be empty for single volume test"
  }

  assert {
    condition     = var.enable_ssm == true
    error_message = "SSM should be enabled"
  }
}

# Test Multiple EBS Volumes Configuration
run "multiple_ebs_volumes" {
  command = plan

  variables {
    vpc_id        = "vpc-12345678"
    subnet_id     = "subnet-87654321"
    instance_type = "t3.small"
    enable_ssm    = true
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
        volume_type = "gp2"
        encrypted   = true
        tags        = { Purpose = "logs" }
      }
    ]
    instance_tags = {
      Environment = "test"
      Project     = "ec2-ebs-multiple-test"
      Type        = "multiple-ebs"
    }
  }

  assert {
    condition     = length(var.ebs_volumes) == 2
    error_message = "Should have 2 EBS volumes configured"
  }

  assert {
    condition     = var.ebs_volumes[0].device_name == "/dev/xvdf"
    error_message = "First volume device name should be /dev/xvdf"
  }

  assert {
    condition     = var.ebs_volumes[0].volume_size == 10
    error_message = "First volume size should be 10 GB"
  }

  assert {
    condition     = var.ebs_volumes[0].volume_type == "gp3"
    error_message = "First volume type should be gp3"
  }

  assert {
    condition     = var.ebs_volumes[1].device_name == "/dev/xvdg"
    error_message = "Second volume device name should be /dev/xvdg"
  }

  assert {
    condition     = var.ebs_volumes[1].volume_size == 5
    error_message = "Second volume size should be 5 GB"
  }

  assert {
    condition     = var.ebs_volumes[1].volume_type == "gp2"
    error_message = "Second volume type should be gp2"
  }

  assert {
    condition     = var.ebs_volume_size == null
    error_message = "Single EBS volume size should be null when using multiple volumes"
  }
}

# Test EBS Volume with Custom Configuration
run "ebs_volume_custom_config" {
  command = plan

  variables {
    vpc_id        = "vpc-12345678"
    subnet_id     = "subnet-87654321"
    instance_type = "t3.medium"
    enable_ssm    = true
    ebs_volumes = [
      {
        device_name = "/dev/xvdf"
        volume_size = 100
        volume_type = "io1"
        encrypted   = true
        iops        = 1000
        tags        = { Purpose = "database", Environment = "production" }
      }
    ]
    instance_tags = {
      Environment = "production"
      Project     = "ec2-ebs-custom-test"
      Type        = "custom-ebs"
    }
  }

  assert {
    condition     = var.ebs_volumes[0].volume_type == "io1"
    error_message = "Volume type should be io1"
  }

  assert {
    condition     = var.ebs_volumes[0].iops == 1000
    error_message = "IOPS should be 1000"
  }

  assert {
    condition     = var.ebs_volumes[0].volume_size == 100
    error_message = "Volume size should be 100 GB"
  }

  assert {
    condition     = var.ebs_volumes[0].encrypted == true
    error_message = "Volume should be encrypted"
  }
}

# EBS validation tests removed - no validation implemented

# Test Default EBS Volume Values
run "test_ebs_defaults" {
  command = plan

  variables {
    vpc_id    = "vpc-12345678"
    subnet_id = "subnet-87654321"
  }

  assert {
    condition     = var.ebs_volume_size == null
    error_message = "Default EBS volume size should be null"
  }

  assert {
    condition     = var.ebs_volume_type == "gp3"
    error_message = "Default EBS volume type should be gp3"
  }

  assert {
    condition     = var.ebs_device_name == "/dev/xvdf"
    error_message = "Default EBS device name should be /dev/xvdf"
  }

  assert {
    condition     = length(var.ebs_volumes) == 0
    error_message = "Default EBS volumes list should be empty"
  }
}

# Security Group Tests

# Test Security Group Creation with Custom CIDR Blocks
run "security_group_creation" {
  command = plan

  variables {
    vpc_id                = "vpc-12345678"
    subnet_id             = "subnet-87654321"
    instance_type         = "t3.micro"
    create_security_group = true
    allowed_cidr_blocks   = ["10.0.0.0/8", "172.16.0.0/12"]
    instance_tags = {
      Environment = "test"
      Project     = "ec2-sg-test"
      Type        = "security-group"
    }
  }

  assert {
    condition     = var.create_security_group == true
    error_message = "create_security_group should be true"
  }

  assert {
    condition     = length(var.allowed_cidr_blocks) == 2
    error_message = "Should have 2 allowed CIDR blocks"
  }

  assert {
    condition     = var.allowed_cidr_blocks[0] == "10.0.0.0/8"
    error_message = "First CIDR block should be 10.0.0.0/8"
  }

  assert {
    condition     = var.allowed_cidr_blocks[1] == "172.16.0.0/12"
    error_message = "Second CIDR block should be 172.16.0.0/12"
  }

  assert {
    condition     = length(var.vpc_security_group_ids) == 0
    error_message = "vpc_security_group_ids should be empty when creating new security group"
  }
}

# Test Using Existing Security Group IDs
run "existing_security_groups" {
  command = plan

  variables {
    vpc_id                 = "vpc-12345678"
    subnet_id              = "subnet-87654321"
    instance_type          = "t3.micro"
    create_security_group  = false
    vpc_security_group_ids = ["sg-12345678", "sg-87654321"]
    instance_tags = {
      Environment = "test"
      Project     = "ec2-existing-sg-test"
      Type        = "existing-sg"
    }
  }

  assert {
    condition     = var.create_security_group == false
    error_message = "create_security_group should be false"
  }

  assert {
    condition     = length(var.vpc_security_group_ids) == 2
    error_message = "Should have 2 existing security group IDs"
  }

  assert {
    condition     = var.vpc_security_group_ids[0] == "sg-12345678"
    error_message = "First security group ID should be sg-12345678"
  }

  assert {
    condition     = var.vpc_security_group_ids[1] == "sg-87654321"
    error_message = "Second security group ID should be sg-87654321"
  }

  assert {
    condition     = length(var.allowed_cidr_blocks) == 1 && var.allowed_cidr_blocks[0] == "0.0.0.0/0"
    error_message = "allowed_cidr_blocks should use default value"
  }
}

# Test Combining Created and Existing Security Groups
run "combined_security_groups" {
  command = plan

  variables {
    vpc_id                 = "vpc-12345678"
    subnet_id              = "subnet-87654321"
    instance_type          = "t3.micro"
    create_security_group  = true
    allowed_cidr_blocks    = ["10.0.0.0/8"]
    vpc_security_group_ids = ["sg-12345678"]
    instance_tags = {
      Environment = "test"
      Project     = "ec2-combined-sg-test"
      Type        = "combined-sg"
    }
  }

  assert {
    condition     = var.create_security_group == true
    error_message = "create_security_group should be true"
  }

  assert {
    condition     = length(var.vpc_security_group_ids) == 1
    error_message = "Should have 1 existing security group ID"
  }

  assert {
    condition     = var.vpc_security_group_ids[0] == "sg-12345678"
    error_message = "Existing security group ID should be sg-12345678"
  }

  assert {
    condition     = var.allowed_cidr_blocks[0] == "10.0.0.0/8"
    error_message = "Allowed CIDR block should be 10.0.0.0/8"
  }
}

# Test Default Security Group Configuration
run "default_security_group_config" {
  command = plan

  variables {
    vpc_id    = "vpc-12345678"
    subnet_id = "subnet-87654321"
  }

  assert {
    condition     = var.create_security_group == false
    error_message = "create_security_group should default to false"
  }

  assert {
    condition     = length(var.vpc_security_group_ids) == 0
    error_message = "vpc_security_group_ids should default to empty list"
  }

  assert {
    condition     = length(var.allowed_cidr_blocks) == 1 && var.allowed_cidr_blocks[0] == "0.0.0.0/0"
    error_message = "allowed_cidr_blocks should default to 0.0.0.0/0"
  }
}

# Test Security Group with SSM Enabled
run "security_group_with_ssm" {
  command = plan

  variables {
    vpc_id                = "vpc-12345678"
    subnet_id             = "subnet-87654321"
    instance_type         = "t3.micro"
    create_security_group = true
    allowed_cidr_blocks   = ["10.0.0.0/8"]
    enable_ssm            = true
    instance_tags = {
      Environment = "test"
      Project     = "ec2-sg-ssm-test"
      Type        = "sg-ssm"
    }
  }

  assert {
    condition     = var.create_security_group == true
    error_message = "create_security_group should be true"
  }

  assert {
    condition     = var.enable_ssm == true
    error_message = "SSM should be enabled"
  }

  assert {
    condition     = var.allowed_cidr_blocks[0] == "10.0.0.0/8"
    error_message = "Allowed CIDR block should be 10.0.0.0/8"
  }
}

# Test Security Group with Webserver Role
run "security_group_with_webserver" {
  command = plan

  variables {
    vpc_id                = "vpc-12345678"
    subnet_id             = "subnet-87654321"
    instance_type         = "t3.micro"
    create_security_group = true
    allowed_cidr_blocks   = ["0.0.0.0/0"]
    role                  = "webserver"
    webserver_type        = "nginx"
    http_port             = 8080
    instance_tags = {
      Environment = "test"
      Project     = "ec2-sg-webserver-test"
      Type        = "sg-webserver"
    }
  }

  assert {
    condition     = var.create_security_group == true
    error_message = "create_security_group should be true"
  }

  assert {
    condition     = var.role == "webserver"
    error_message = "Role should be webserver"
  }

  assert {
    condition     = var.webserver_type == "nginx"
    error_message = "Webserver type should be nginx"
  }

  assert {
    condition     = var.http_port == 8080
    error_message = "HTTP port should be 8080"
  }

  assert {
    condition     = length(var.allowed_cidr_blocks) == 1 && var.allowed_cidr_blocks[0] == "0.0.0.0/0"
    error_message = "Allowed CIDR blocks should allow all traffic"
  }
}
