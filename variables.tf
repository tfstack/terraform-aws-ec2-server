variable "vpc_id" {
  description = "ID of the VPC"
  type        = string

  validation {
    condition     = can(regex("^vpc-", var.vpc_id))
    error_message = "VPC ID must be a valid vpc-* format."
  }
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance"
  type        = string

  validation {
    condition     = can(regex("^subnet-", var.subnet_id))
    error_message = "Subnet ID must be a valid subnet-* format."
  }
}

variable "name" {
  description = "Name prefix for resources (e.g., 'my-server', 'web-app')"
  type        = string
  default     = "ec2-server"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.name))
    error_message = "Name must contain only alphanumeric characters and hyphens."
  }
}

variable "ami_type" {
  description = "AMI type (default supports only `amazonlinux2`)"
  type        = string
  default     = "amazonlinux2"

  validation {
    condition     = contains(["amazonlinux2"], var.ami_type)
    error_message = "AMI type must be 'amazonlinux2'."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = can(regex("^[a-z0-9]+\\.[a-z0-9]+$", var.instance_type))
    error_message = "Instance type must be a valid AWS instance type (e.g., t3.micro, t3.small)."
  }
}

variable "role" {
  description = "Optional server role (e.g., `webserver`)"
  type        = string
  default     = null

  validation {
    condition     = var.role == null || var.role == "webserver"
    error_message = "Role must be 'webserver' or null."
  }
}

variable "webserver_type" {
  description = "Webserver type if role is `webserver` (`nginx` or `apache`)"
  type        = string
  default     = "nginx"

  validation {
    condition     = contains(["nginx", "apache"], var.webserver_type)
    error_message = "Webserver type must be 'nginx' or 'apache'."
  }
}

variable "http_port" {
  description = "HTTP port for webserver (default: 80)"
  type        = number
  default     = 80

  validation {
    condition     = var.http_port >= 1 && var.http_port <= 65535
    error_message = "HTTP port must be between 1 and 65535."
  }
}

variable "user_data" {
  description = "Optional custom user data script"
  type        = string
  default     = null
}

variable "enable_ssm" {
  description = "Enable SSM access. Note: For SSM to work with public IP, ensure the instance is in a public subnet with route to internet gateway."
  type        = bool
  default     = false
}

variable "assign_public_ip" {
  description = "Assign public IP to instance. Note: For SSM to work with public IP, ensure the instance is in a public subnet with route to internet gateway."
  type        = bool
  default     = false
}

variable "enable_cw_logs" {
  description = "Enable CloudWatch Logs agent (writes basic system logs to CW Logs)"
  type        = bool
  default     = false
}

variable "instance_tags" {
  description = "Tags to apply to the instance"
  type        = map(string)
  default     = {}
}

# EBS Volume Configuration
variable "ebs_volume_size" {
  description = "Size of the EBS volume in GB (for single volume configuration)"
  type        = number
  default     = null
}

variable "ebs_volume_type" {
  description = "Type of EBS volume (for single volume configuration)"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "sc1", "st1"], var.ebs_volume_type)
    error_message = "EBS volume type must be one of: gp2, gp3, io1, io2, sc1, st1."
  }
}

variable "ebs_device_name" {
  description = "Device name for the EBS volume (for single volume configuration)"
  type        = string
  default     = "/dev/xvdf"

  validation {
    condition     = can(regex("^/dev/[a-z]+$", var.ebs_device_name))
    error_message = "EBS device name must be a valid device path (e.g., /dev/xvdf)."
  }
}

variable "ebs_volumes" {
  description = "List of EBS volumes to attach to the instance"
  type = list(object({
    device_name = string
    volume_size = number
    volume_type = string
    encrypted   = optional(bool, true)
    kms_key_id  = optional(string, null)
    iops        = optional(number, null)
    throughput  = optional(number, null)
    tags        = optional(map(string), {})
  }))
  default = []

  validation {
    condition = alltrue([
      for vol in var.ebs_volumes : can(regex("^/dev/[a-z]+$", vol.device_name))
    ])
    error_message = "All EBS device names must be valid device paths (e.g., /dev/xvdf)."
  }

  validation {
    condition = alltrue([
      for vol in var.ebs_volumes : vol.volume_size >= 1 && vol.volume_size <= 16384
    ])
    error_message = "All EBS volume sizes must be between 1 and 16384 GB."
  }

  validation {
    condition = alltrue([
      for vol in var.ebs_volumes : contains(["gp2", "gp3", "io1", "io2", "sc1", "st1"], vol.volume_type)
    ])
    error_message = "All EBS volume types must be one of: gp2, gp3, io1, io2, sc1, st1."
  }
}
