# lxd_btrfs_to_zfs (works with DIR too)
Script to move container data from btrfs to zfs storage

# How to move from BTRFS backend to ZFS backend

# Links for help
+Follow this guide to enable ZFS backend storage to LXD
https://insights.ubuntu.com/2015/11/06/using-lxd-with-a-file-based-zfs-pool-on-ubuntu-wily/

# Quick how-to guide 
1. Stop LXD && LXC 
2. Unmount your btrfs storage from /var/lib/lxd 
3. Mount your btrfs storage to another path like /mnt/lxd
4. Create a new direcotry /var/lib/lxd 
5. Copy lxd files from your btrfs path (/mnt/lxd) to you new lxd directory /var/lib/lxd . This will keep the lxd.db and containers info
6. Enable and create your ZFS Zpool (do not mount the pool to /var/lib/lxd but somewhere else)
  > mkdir /lxd-pool
  > zfs set mountpoint=/lxd-zpool lxd-zpool
7. Use the script to migrate data 

#IMPORTANT 
Be sure that LXD is configured and see that you are not using BTRFS anymore.

In my case, even after removing BTRFS volume to /var/lib/lxd  the LXD daemon was mounting my volume itslef to /var/lib/lxd .

I did not undestand why, but I had to reboot the system before LXD stop using BTRFS as a backendstorage .


Try on your lab system first. 
