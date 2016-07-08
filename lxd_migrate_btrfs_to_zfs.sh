#!/bin/bash
#
# Date 		: 2016-07-07
# Version 	: 1.0
# Par 		: Benoit Georgelin - Web4all Team
# Desc 		: Migrate LXC/LXD containers from BTRFS to ZFS local storage
# Github	: https://github.com/givre/lxd_btrfs_to_zfs/
# 
#
# Steps: 
#  1: Check if container path exist in the BTRFS (old) LXD_DIR
#  2: Check if container path does not already exist in the new ZFS storage
#  3: Create folders used by LXD including the symbolic link in LXD_DIR/container
#  4: Create ZFS volume for the container using the specific mountpoint as LXD would do
#  5: Rsync the date from OLD path to NEW path
#  6: Set device disk ROOT quota 
#  7: Start the container

#----- Start of Configuration 

_LXD_OLD_DIR="/mnt/lxd"
_LXD_NEW_DIR="/var/lib/lxd"
_ZFS_POOL_NAME="lxd-zpool"
_HD_GB_SIZE="10"
_START_CONTAINER=1
_CMD_START_CONTAINER="/opt/lxd_deploy/container/start_container.sh -n ${_CT}"  #default : lxc start ${_CT}

#------ End Of Configuration 

cd ${_LXD_OLD_DIR}/containers


for _CT in `ls|grep -Ev '\.zfs|\.log'`; do


	if [ -d "${_LXD_OLD_DIR}/containers/$_CT" ] ; then 

		echo "----- $_CT -----"

		if [ ! -d "${_LXD_NEW_DIR}/containers/${_CT}" ]; then

			#Container does not exit on destionation we can migrate
			mkdir "${_LXD_NEW_DIR}/containers/${_CT}.zfs"
			cd ${_LXD_NEW_DIR}/containers
			ln -s ${_CT}.zfs ${_CT}

			# Create ZFS Vol
			zfs create -o mountpoint=${_LXD_NEW_DIR}/containers/${_CT}.zfs ${_ZFS_POOL_NAME}/containers/${_CT}
			rsync -avz ${_LXD_OLD_DIR}/containers/${_CT}/ ${_LXD_NEW_DIR}/containers/${_CT}.zfs/


			# Set default disk size 
			lxc config device set ${_CT} root size ${_HD_GB_SIZE}GB

			# Start container
			[ $_START_CONTAINER == 1 ] && ${_CMD_START_CONTAINER}

		else 
				echo "Container $_CT already exist on destiantion folder ${_LXD_NEW_DIR}/containers/${_CT}"
		fi

	else 
		echo " ${_LXD_OLD_DIR}/containers/${_CT} does not exist"

	fi

done
