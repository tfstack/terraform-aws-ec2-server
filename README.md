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
| [aws_iam_instance_profile.ec2_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ec2_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.ec2_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_ami.amazon_linux_2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ami_type"></a> [ami\_type](#input\_ami\_type) | AMI type (default supports only `amazonlinux2`) | `string` | `"amazonlinux2"` | no |
| <a name="input_assign_public_ip"></a> [assign\_public\_ip](#input\_assign\_public\_ip) | Assign public IP to instance. Note: For SSM to work with public IP, ensure the instance is in a public subnet with route to internet gateway. | `bool` | `false` | no |
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
| <a name="input_webserver_type"></a> [webserver\_type](#input\_webserver\_type) | Webserver type if role is `webserver` (`nginx` or `apache`) | `string` | `"nginx"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | EC2 instance ID |
| <a name="output_private_ip"></a> [private\_ip](#output\_private\_ip) | Private IP address |
| <a name="output_public_ip"></a> [public\_ip](#output\_public\_ip) | Public IP address |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security Group ID |
| <a name="output_ssm_instance_url"></a> [ssm\_instance\_url](#output\_ssm\_instance\_url) | SSM Console Session URL (if SSM enabled) |
<!-- END_TF_DOCS -->
