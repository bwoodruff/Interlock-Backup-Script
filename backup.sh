#!/bin/bash

#####################################
# INTERLOCK ROCHESTER BACKUP SCRIPT #
# Compiled by Ben Woodruff          #
# Idea based on Michael Jakl's work #
#####################################

# Edit the below variables to suit your environment

# Mount point of your backup drive
rootvol=/Volumes/bdw-bk

# Mount point of your disk image
destroot=/Volumes/DBBackup

# Path to your disk image
img=/Volumes/bdw-bk/DBBackup.sparsebundle

# Directory to backup
src=$HOME

# Date format - you probably don't need to change this
date=`date "+%Y-%m-%dT%H-%M-%S"`

#####################################
No edits required below this line
#####################################

# If the requested image exists
if [ -e $img ]

	# mount the image
	hdid $img 
	# if it mounted successfully
	if [ $? -eq 0 ]
		# setup the required directory structure and fail gracefully if it already exists
		mkdir -p $destroot/Backups $destroot/Backups/current $destroot/Backups/back-$date 2>/dev/null

		echo Backing up $src to $destroot/Backups/back-$date using $destroot/Backups/current as link dest...
		echo Please do not disconnect your backup volume!

		sleep 2

		rsync -azvxP --delete-excluded --exclude-from=NOBAK.txt --link-dest=$destroot/Backups/current $src $destroot/Backups/back-$date

		echo Backup completed... cleaning up.
		
		# what was the current backup no longer is because we just created a new one
		# so delete the 'current' reference
		if [ -e $destroot/Backups/current ]
			rm -f $destroot/Backups/current
		fi
		# link the backup we just created to 'current'
		ln -s back-$date $destroot/Backups/current
		
		#unmount the disk image
		umount $destroot
	fi

fi

# unmount the drive
umount $rootvol

echo It is now safe to disconnect the backup volume