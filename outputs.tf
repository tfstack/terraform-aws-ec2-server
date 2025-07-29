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
  description = "Security Group ID"
  value       = aws_security_group.ec2_server.id
}

output "ssm_instance_url" {
  description = "SSM Console Session URL (if SSM enabled)"
  value       = var.enable_ssm ? "https://console.aws.amazon.com/systems-manager/session-manager/${aws_instance.server.id}" : null
}
