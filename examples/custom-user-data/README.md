# Custom User Data Example

This example demonstrates how to create an EC2 instance with custom user data using the `terraform-aws-ec2-server` module.

## Features

- **Custom User Data Script**: Overrides the default module behavior with a simple nginx setup
- **Web Server**: Installs and configures nginx with a basic test page
- **Public Access**: Configured with public IP and HTTP ingress for testing

## Infrastructure Created

- VPC with public and private subnets
- EC2 instance in public subnet with public IP
- Security group with HTTP ingress (port 80)
- Custom user data script that installs nginx

## What Gets Installed & Configured

The user data script performs these steps:

1. **System Update**: Updates all system packages
2. **Nginx Installation**: Installs nginx web server using amazon-linux-extras
3. **Test Page**: Creates a simple HTML test page
4. **Service Management**: Starts and enables nginx service

## Access

### Web Access

Once deployed, you can access the test page at:

```plaintext
http://<public_ip>/
```

### Check User Data Logs

View the user data script execution logs:

```bash
cat /var/log/user-data.log
```

## Outputs

- `instance_id`: ID of the EC2 instance
- `public_ip`: Public IP address for web access

## Use Cases

- **Testing**: Quick validation of custom user data scripts
- **Learning**: Understanding how to override default module behavior
- **Prototyping**: Simple web server setup for development

## Troubleshooting

If the web page doesn't load:

1. **Check user data logs**:

   ```bash
   cat /var/log/user-data.log
   ```

2. **Verify nginx is running**:

   ```bash
   systemctl status nginx
   ```

3. **Test locally on instance**:

   ```bash
   curl http://localhost/
   ```
