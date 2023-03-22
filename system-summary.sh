#!/bin/bash
# This script prints system summary

# Get some basic Infos as distro, kernel rev, date, timezone, uptime and hostname
hostname=$(hostname)
distro=$(cat /etc/os-release |grep -i PRETTY_NAME | sed 's/PRETTY_NAME=//g')
kernel=$(uname -r)
date=$(date +"%Y-%m-%d")
tz=$(cat /etc/timezone)
uptime=$(uptime -p)

echo "System Summary"
echo "=============="

echo "Hostname: $hostname"
echo "Distribution: $distro"
echo "Kernel: $kernel"
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

if type multipath > /dev/null 2>&1; then
  echo "Multipath is available"
  multipath status
fi

if type fcinfo > /dev/null 2>&1; then
  echo "FC is available"
  fcinfo status
fi

if type vgs > /dev/null 2>&1 && type lvs > /dev/null 2>&1; then
  echo "LVM is available"
  vgs; lvs
fi

if type mdadm > /dev/null 2>&1; then
  echo "Software RAID is available"
  cat /proc/mdstat
  for md in /dev/md*; do
    mdadm --detail $md
  done
fi

if type iscsiadm > /dev/null 2>&1; then
  echo "iSCSI is available"
  iscsiadm --mode node --op show
fi

echo "=============="
echo "Latest Updates:"

if [ "$(which yum)" != "" ]; then
  echo "Yum package manager used"
  yum history list allvi sys  
elif [ "$(which apt)" != "" ]; then
  echo "Apt package manager used"
  zcat /var/log/apt/history.log.* |
  cat /var/log/apt/history.log |
  grep "apt-get install" | sort -u
fi

echo "=============="
echo "Containers:"

if type docker > /dev/null 2>&1; then
  echo "Docker is available"
  docker ps
fi

if type podman > /dev/null 2>&1; then
  echo "Podman is available"
  podman ps
fi

echo "=============="
echo "Running and failed Services:"

echo "Systemd services:"
systemctl list-units --type=service
systemctl list-units --type=service --state=failed

echo "=============="
echo "Databases detected:"

if type hdbsql > /dev/null 2>&1; then
  echo "HANA is detected"
fi