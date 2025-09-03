#!/bin/bash

# Set hostname
hostnamectl set-hostname ${hostname}

# Update system
yum update -y

# Install required packages
yum install -y xfsprogs

# Function to mount a single EBS volume
mount_ebs_volume() {
    local device=$1
    local mount_point=$2
    local purpose=$3

    echo "Processing EBS volume: $device -> $mount_point ($purpose)"

    # Wait for EBS volume to be attached
    while [ ! -e $device ]; do
        echo "Waiting for EBS volume $device to be attached..."
        sleep 5
    done

    # Check if volume is already formatted
    if ! blkid $device; then
        echo "Formatting EBS volume $device..."
        mkfs.xfs $device
    fi

    # Create mount point
    mkdir -p $mount_point

    # Mount the volume
    mount $device $mount_point

    # Add to fstab for persistent mounting
    echo "$device $mount_point xfs defaults,nofail 0 2" >> /etc/fstab

    # Create a test file to verify the mount
    echo "EBS volume mounted successfully at $mount_point (Purpose: $purpose)" > $mount_point/test.txt

    # Set proper permissions
    chmod 755 $mount_point

    echo "EBS volume $device mounted successfully at $mount_point"
}

# Mount the primary volume (passed as template variable)
mount_ebs_volume ${ebs_device} ${mount_path} "primary"

# Check for additional volumes and mount them
# For multiple volumes example, we'll mount the second volume at /mnt/logs
if [ -e "/dev/xvdg" ]; then
    mount_ebs_volume "/dev/xvdg" "/mnt/logs" "logs"
fi

# Check for any other EBS volumes that might be attached
for device in /dev/xvdh /dev/xvdi /dev/xvdj /dev/xvdk /dev/xvdl /dev/xvdm /dev/xvdn /dev/xvdo /dev/xvdp; do
    if [ -e "$device" ]; then
        # Create a mount point based on device name
        mount_point="/mnt/$(basename $device)"
        mount_ebs_volume "$device" "$mount_point" "additional"
    fi
done

echo "All EBS volumes setup completed successfully"
