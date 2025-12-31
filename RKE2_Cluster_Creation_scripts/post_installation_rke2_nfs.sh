#!/bin/bash

set -e
DISK="/dev/sdb"  # Replace with your disk, e.g., /dev/sdb
SIZE="100G"  # e.g., +20G
MOUNT_POINT="/mnt/rke2-storage"

echo "Step 1: Checking disk info for $DISK..."
sudo fdisk -l "$DISK"

echo "Step 2: Creating new partition on $DISK of size $SIZE..."

sudo fdisk "$DISK" <<EOF
n
p
1


$SIZE
w
EOF

echo "Partition created. Waiting for system to refresh partition table..."
sleep 2

# Get the name of the newly created partition (assumes it's the last one)
NEW_PARTITION=$(ls ${DISK}* | grep -E "${DISK}[0-9]+$" | tail -n1)

echo "Step 3: Formatting $NEW_PARTITION as ext4..."
sudo mkfs.ext4 "$NEW_PARTITION"

echo "Done! New partition $NEW_PARTITION has been formatted and is ready to use."

echo "Step 4: Creating mount point at $MOUNT_POINT..."
sudo mkdir -p "$MOUNT_POINT"

echo "Step 5: Mounting $NEW_PARTITION to $MOUNT_POINT..."
sudo mount "$NEW_PARTITION" "$MOUNT_POINT"

UUID=$(sudo blkid -s UUID -o value "$NEW_PARTITION")

echo "Step 6: Adding to /etc/fstab for persistence..."
echo "UUID=$UUID  $MOUNT_POINT  ext4  defaults  0  2" | sudo tee -a /etc/fstab

echo " Done! $NEW_PARTITION is mounted at $MOUNT_POINT and added to /etc/fstab."

#Installing NFS server and createing export for RKE2
sudo apt update
sudo apt install -y nfs-kernel-server
sudo chown nobody:nogroup "$MOUNT_POINT"
sudo chmod 777 "$MOUNT_POINT"
EXPORT_RULE="*"
EXPORT_OPTIONS="rw,sync,no_subtree_check,no_root_squash"
EXPORT_LINE="$MOUNT_POINT  $EXPORT_RULE($EXPORT_OPTIONS)"
echo "$EXPORT_LINE" | sudo tee -a /etc/exports
sudo exportfs -rav
sudo systemctl restart nfs-kernel-server
