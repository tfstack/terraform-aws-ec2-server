output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.server.id
}

output "public_ip" {
  description = "Public IP address"
  value       = aws_instance.server.public_ip
}

output "private_ip" {
  description = "Private IP address"
  value       = aws_instance.server.private_ip
}

output "security_group_id" {
  description = "Security Group ID (if created)"
  value       = var.create_security_group ? aws_security_group.ec2_server[0].id : null
}

output "effective_security_group_ids" {
  description = "List of security group IDs attached to the instance"
  value       = local.effective_security_group_ids
}

output "ssm_instance_url" {
  description = "SSM Console Session URL (if SSM enabled)"
  value       = var.enable_ssm ? "https://console.aws.amazon.com/systems-manager/session-manager/${aws_instance.server.id}" : null
}

output "ebs_volume_ids" {
  description = "List of EBS volume IDs attached to the instance"
  value = concat(
    var.ebs_volume_size != null ? [aws_ebs_volume.single[0].id] : [],
    [for vol in aws_ebs_volume.multiple : vol.id]
  )
}

output "ebs_volume_attachments" {
  description = "Map of device names to volume IDs for attached EBS volumes"
  value = merge(
    var.ebs_volume_size != null ? { (var.ebs_device_name) = aws_ebs_volume.single[0].id } : {},
    { for k, vol in aws_ebs_volume.multiple : k => vol.id }
  )
}
