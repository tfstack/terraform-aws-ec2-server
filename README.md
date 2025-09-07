# terraform-aws-ec2-server

Provision a single EC2 instance with optional  server role and SSM support

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.multiple](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_ebs_volume.single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_iam_instance_profile.ec2_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ec2_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.ec2_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_volume_attachment.multiple](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_volume_attachment.single](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_ami.amazon_linux_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | List of CIDR blocks allowed to access the instance via SSH and ICMP | `list(string)` | <pre>[<br/>  "0.0.0.0/0"<br/>]</pre> | no |
| <a name="input_ami_type"></a> [ami\_type](#input\_ami\_type) | AMI type (default supports only `amazonlinux2`) | `string` | `"amazonlinux2"` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign public IP to instance. Note: For SSM to work with public IP, ensure the instance is in a public subnet with route to internet gateway. | `bool` | `false` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | Create a dedicated security group allowing SSH/ICMP from allowed CIDRs if no security group IDs are supplied. If true, vpc\_security\_group\_ids can be empty. | `bool` | `false` | no |
| <a name="input_ebs_device_name"></a> [ebs\_device\_name](#input\_ebs\_device\_name) | Device name for the EBS volume (for single volume configuration) | `string` | `"/dev/xvdf"` | no |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | Size of the EBS volume in GB (for single volume configuration) | `number` | `null` | no |
| <a name="input_ebs_volume_type"></a> [ebs\_volume\_type](#input\_ebs\_volume\_type) | Type of EBS volume (for single volume configuration) | `string` | `"gp3"` | no |
| <a name="input_ebs_volumes"></a> [ebs\_volumes](#input\_ebs\_volumes) | List of EBS volumes to attach to the instance | <pre>list(object({<br/>    device_name = string<br/>    volume_size = number<br/>    volume_type = string<br/>    encrypted   = optional(bool, true)<br/>    kms_key_id  = optional(string, null)<br/>    iops        = optional(number, null)<br/>    throughput  = optional(number, null)<br/>    tags        = optional(map(string), {})<br/>  }))</pre> | `[]` | no |
| <a name="input_enable_cw_logs"></a> [enable\_cw\_logs](#input\_enable\_cw\_logs) | Enable CloudWatch Logs agent (writes basic system logs to CW Logs) | `bool` | `false` | no |
| <a name="input_enable_ssm"></a> [enable\_ssm](#input\_enable\_ssm) | Enable SSM access. Note: For SSM to work with public IP, ensure the instance is in a public subnet with route to internet gateway. | `bool` | `false` | no |
| <a name="input_http_port"></a> [http\_port](#input\_http\_port) | HTTP port for webserver (default: 80) | `number` | `80` | no |
| <a name="input_instance_tags"></a> [instance\_tags](#input\_instance\_tags) | Tags to apply to the instance | `map(string)` | `{}` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 instance type | `string` | `"t3.micro"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name prefix for resources (e.g., 'my-server', 'web-app') | `string` | `"ec2-server"` | no |
| <a name="input_role"></a> [role](#input\_role) | Optional server role (e.g., `webserver`) | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Subnet ID to launch the instance | `string` | n/a | yes |
| <a name="input_user_data"></a> [user\_data](#input\_user\_data) | Optional custom user data script | `string` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC | `string` | n/a | yes |
| <a name="input_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#input\_vpc\_security\_group\_ids) | List of security group IDs to attach to the instance. | `list(string)` | `[]` | no |
| <a name="input_webserver_type"></a> [webserver\_type](#input\_webserver\_type) | Webserver type if role is `webserver` (`nginx` or `apache`) | `string` | `"nginx"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ebs_volume_attachments"></a> [ebs\_volume\_attachments](#output\_ebs\_volume\_attachments) | Map of device names to volume IDs for attached EBS volumes |
| <a name="output_ebs_volume_ids"></a> [ebs\_volume\_ids](#output\_ebs\_volume\_ids) | List of EBS volume IDs attached to the instance |
| <a name="output_effective_security_group_ids"></a> [effective\_security\_group\_ids](#output\_effective\_security\_group\_ids) | List of security group IDs attached to the instance |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | EC2 instance ID |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Private IP address |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Public IP address |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security Group ID (if created) |
| <a name="output_ssm_instance_url"></a> [ssm\_instance\_url](#output\_ssm\_instance\_url) | SSM Console Session URL (if SSM enabled) |
<!-- END_TF_DOCS -->
