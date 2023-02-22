#!/bin/bash
# This script prints system summary

# Get distribution name
distro=$(cat /etc/os-release |grep -i PRETTY_NAME | sed 's/PRETTY_NAME=//g')

# Get kernel version
kernel=$(uname -r)

# Get current date and Timezone
date=$(date +"%Y-%m-%d")
tz=$(cat /etc/timezone)

# Get uptime
uptime=$(uptime -p)

# Get Hostname
hostname=$(hostname)

# Print header
echo "System Summary"
echo "=============="

# Print distribution, kernel, date, uptime
echo "Distribution: $distro"
echo "Kernel: $kernel"
echo "Hostname: $hostname"
echo "Date: $date $tz"
echo "Uptime: $uptime"

# Print mounted filesystems
echo "Mounted Filesystems:"
mount | column -t |egrep "ext3|ext4|xfs|_netdev|cifs|nfs|btrfs"

# Print disk usage
echo "=============="
echo "Disk Usage and Storage Informations:"
df -h
lsblk

# Check if multipath is available
if type multipath > /dev/null 2>&1; then
  echo "Multipath is available"
  # Print multipath information (replace this command with your own)
  multipath status
fi

# Check if fcinfo is available
if type fcinfo > /dev/null 2>&1; then
  echo "FC is available"
  # Print FC information (replace this command with your own)
  fcinfo status
fi

# Check if vgs and lvs are available
if type vgs > /dev/null 2>&1 && type lvs > /dev/null 2>&1; then
  echo "LVM is available"
  # Print LVM information
  vgs; lvs
fi

# Check if mdadm is available
if type mdadm > /dev/null 2>&1; then
  echo "Software RAID is available"
  # List software RAID devices
  cat /proc/mdstat
  # Print details of each software RAID device
  for md in /dev/md*; do
    mdadm --detail $md
    # Print disks and size of each software RAID device
#    lsblk -o NAME,SIZE $md
  done
fi

# Check if iscsiadm is available
if type iscsiadm > /dev/null 2>&1; then
  echo "iSCSI is available"
  # Print iSCSI information (replace this command with your own)
  iscsiadm --mode node --op show
fi

## Check messages for failures (replace this command with your own)
#failures=$(grep -i fail /var/log/messages)
#if [ "$failures" != "" ]; then
#  echo "Failures found in messages:"
#  # Print failures
#  grep -i fail /var/log/messages
#fi

echo "=============="
echo "Latest Updates:"

# Check update history based on package manager used (replace this command with your own)
if [ "$(which yum)" != "" ]; then
  echo "Yum package manager used"
  # Print yum update history (replace this command with your own)
  yum history list all
elif [ "$(which apt)" != "" ]; then
  echo "Apt package manager used"
  # Print apt update history (replace this command with your own)
  zcat "/var/log/apt/history.log.* |"

echo "=============="
echo "Containers found:"

# Check if docker is available
if type docker > /dev/null 2>&1; then
  echo "Docker is available"
  # List docker containers
  docker ps
fi

# Check if podman is available
if type podman > /dev/null 2>&1; then
  echo "Podman is available"
  # List podman containers
  podman ps
fi

echo "=============="
echo "Running and failed Services:"

# List systemd services
echo "Systemd services:"
# List all loaded and active services
systemctl list-units --type=service
# List all loaded but failed services
systemctl list-units --type=service --state=failed

echo "=============="
echo "Databases detected:"

# Check if HANA is running
if type hdbsql > /dev/null 2>&1; then
  echo "HANA is detected"
fi

# Check if MariaDB is running
if type mysql > /dev/null 2>&1; then
  echo "MariaDB is detected"
fi

# Check if PostgreSQL is running
if type psql > /dev/null 2>&1; then
  echo "PostgreSQL is detected"
fi

# Check if Oracle is running
if type sqlplus > /dev/null 2>&1; then
  echo "Oracle DB is available"
fi