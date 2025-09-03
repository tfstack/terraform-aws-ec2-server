# EBS Volumes Example

This example demonstrates how to create EC2 instances with EBS volumes using the `terraform-aws-ec2-server` module.

## Features

- **Single EBS Volume**: Simple configuration with one EBS volume
- **Multiple EBS Volumes**: Advanced configuration with multiple EBS volumes
- **Automatic Mounting**: User data script automatically formats and mounts volumes
- **SSM Access**: Both instances have SSM access enabled for management

## Infrastructure Created

- VPC with public and private subnets
- Two EC2 instances in private subnets
- EBS volumes attached to each instance
- Security groups and IAM roles for SSM access

## EBS Volume Configurations

### Single Volume Instance

- **Volume Size**: 10 GB
- **Volume Type**: gp3
- **Device Name**: /dev/xvdf
- **Mount Point**: /mnt

### Multiple Volumes Instance

- **Volume 1**: 10 GB gp3 volume at /dev/xvdf (content)
- **Volume 2**: 5 GB gp3 volume at /dev/xvdg (logs)

## What Gets Installed & Configured

The user data script performs these steps:

1. **System Update**: Updates all system packages
2. **Package Installation**: Installs xfsprogs for XFS filesystem support
3. **Volume Detection**: Waits for EBS volume to be attached
4. **Volume Formatting**: Formats the volume with XFS filesystem (if not already formatted)
5. **Volume Mounting**: Mounts the volume to the specified mount point
6. **Persistent Mount**: Adds entry to /etc/fstab for automatic mounting on reboot
7. **Verification**: Creates a test file to verify successful mounting

## Access

### SSM Session Manager

Connect to instances using AWS Systems Manager Session Manager:

```bash
# For single volume instance
aws ssm start-session --target <single-instance-id>

# For multiple volumes instance
aws ssm start-session --target <multiple-instance-id>
```

### Verify EBS Volumes

Once connected via SSM, verify the EBS volumes:

```bash
# Check mounted volumes
df -h

# Check volume details
lsblk

# Verify test file
cat /mnt/test.txt
```

## Outputs

- `instance_id`: ID of the EC2 instance
- `ebs_volume_ids`: List of EBS volume IDs attached to the instance
- `ebs_volume_attachments`: Map of device names to volume IDs

## Use Cases

- **Data Storage**: Persistent storage for applications
- **Log Storage**: Dedicated volumes for log files
- **Database Storage**: Separate volumes for database data
- **Backup Storage**: Dedicated volumes for backup data

## Troubleshooting

If volumes don't mount properly:

1. **Check user data logs**:

   ```bash
   cat /var/log/user-data.log
   ```

2. **Check volume attachment**:

   ```bash
   lsblk
   ```

3. **Check mount status**:

   ```bash
   mount | grep /mnt
   ```

4. **Manually mount if needed**:

   ```bash
   sudo mount /dev/xvdf /mnt
   ```

## Cost Considerations

- EBS volumes are charged based on size and type
- gp3 volumes are cost-effective for most workloads
- Consider using smaller volumes for development/testing
- Remember to delete resources when done to avoid charges
