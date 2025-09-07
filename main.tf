# Data source for Amazon Linux 2 AMI
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group
resource "aws_security_group" "ec2_server" {
  count = var.create_security_group ? 1 : 0

  name_prefix = "${var.name}-sg-"
  vpc_id      = var.vpc_id

  # Egress - allow all outbound traffic (required for SSM)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress - allow HTTP if webserver role
  dynamic "ingress" {
    for_each = var.role == "webserver" ? [1] : []
    content {
      from_port   = var.http_port
      to_port     = var.http_port
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = merge(var.instance_tags, {
    Name = "${var.name}-sg"
  })
}

# Derived locals for effective security group IDs
locals {
  effective_security_group_ids = (
    var.create_security_group ? (
      length(var.vpc_security_group_ids) > 0 ? concat(var.vpc_security_group_ids, [aws_security_group.ec2_server[0].id]) : [aws_security_group.ec2_server[0].id]
    ) : var.vpc_security_group_ids
  )
}

# IAM Role for EC2 instance
resource "aws_iam_role" "ec2_server" {
  count = var.enable_ssm || var.enable_cw_logs ? 1 : 0

  name = "${var.name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.instance_tags
}

# IAM Instance Profile
resource "aws_iam_instance_profile" "ec2_server" {
  count = var.enable_ssm || var.enable_cw_logs ? 1 : 0

  name = "${var.name}-profile"
  role = aws_iam_role.ec2_server[0].name
}

# Attach SSM policy if enabled
resource "aws_iam_role_policy_attachment" "ssm" {
  count = var.enable_ssm ? 1 : 0

  role       = aws_iam_role.ec2_server[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach CloudWatch policy if enabled
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count = var.enable_cw_logs ? 1 : 0

  role       = aws_iam_role.ec2_server[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# EC2 Instance
resource "aws_instance" "server" {
  ami                    = data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = local.effective_security_group_ids
  iam_instance_profile   = var.enable_ssm || var.enable_cw_logs ? aws_iam_instance_profile.ec2_server[0].name : null

  # Use user_data for plain text, user_data_base64 for encoded
  user_data = var.user_data != null ? var.user_data : (local.user_data_script != "" ? local.user_data_script : null)

  user_data_replace_on_change = true

  associate_public_ip_address = var.assign_public_ip

  tags = merge(var.instance_tags, {
    Name = var.name
  })

  depends_on = [
    aws_iam_role_policy_attachment.ssm,
    aws_iam_role_policy_attachment.cloudwatch
  ]
}

# EBS Volume for single volume configuration
resource "aws_ebs_volume" "single" {
  count = var.ebs_volume_size != null ? 1 : 0

  availability_zone = aws_instance.server.availability_zone
  size              = var.ebs_volume_size
  type              = var.ebs_volume_type
  encrypted         = true

  tags = merge(var.instance_tags, {
    Name = "${var.name}-ebs-volume"
  })
}

# EBS Volume attachment for single volume
resource "aws_volume_attachment" "single" {
  count = var.ebs_volume_size != null ? 1 : 0

  device_name = var.ebs_device_name
  volume_id   = aws_ebs_volume.single[0].id
  instance_id = aws_instance.server.id
}

# EBS Volumes for multiple volumes configuration
resource "aws_ebs_volume" "multiple" {
  for_each = { for vol in var.ebs_volumes : vol.device_name => vol }

  availability_zone = aws_instance.server.availability_zone
  size              = each.value.volume_size
  type              = each.value.volume_type
  encrypted         = each.value.encrypted
  kms_key_id        = each.value.kms_key_id
  iops              = each.value.iops
  throughput        = each.value.throughput

  tags = merge(var.instance_tags, each.value.tags, {
    Name = "${var.name}-ebs-volume-${replace(each.value.device_name, "/", "-")}"
  })
}

# EBS Volume attachments for multiple volumes
resource "aws_volume_attachment" "multiple" {
  for_each = { for vol in var.ebs_volumes : vol.device_name => vol }

  device_name = each.value.device_name
  volume_id   = aws_ebs_volume.multiple[each.key].id
  instance_id = aws_instance.server.id
}
