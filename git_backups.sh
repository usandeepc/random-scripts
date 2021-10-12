#!/bin/bash

echo "Git Backups"
GIT_BACKUP_BASE_PATH=/media/disk2/git_backups/
cd $GIT_BACKUP_BASE_PATH
for i in $(ls)
do
	if [ -d $i ]
	then
		echo ""
		echo "********START OF BACKUP $i Repo************"
		_dow="$(date +'%A')";
		_db_backup_file="${i}_${_dow}.tar.gz";
		_db_backup_tmp_file="${i}_tmp.tar.gz";
		if [ ! -f $GIT_BACKUP_BASE_PATH$_db_backup_file ]; 
		then
			echo "$_db_backup_file file does not exist";
		else
			echo "$_db_backup_file file exists, moving to $_db_backup_tmp_file";
			mv $GIT_BACKUP_BASE_PATH$_db_backup_file $GIT_BACKUP_BASE_PATH$_db_backup_tmp_file;
		fi
		cd $i;
		echo "Inside Folder $GIT_BACKUP_BASE_PATH$i";
		echo "Fetching Repo $i";
		git fetch -p;
		cd ..;
		echo "compressing path $i"
		tar -czf $_db_backup_file $i;
		if [ $? -ne 0 ];
		then
			echo "Something went wrong, moving back the  $_db_backup_tmp_file file"
			mv $GIT_BACKUP_BASE_PATH$_db_backup_tmp_file $GIT_BACKUP_BASE_PATH$_db_backup_file
		else
			echo "Cleaning up $_db_backup_tmp_file file. Backup is complete."
			rm $GIT_BACKUP_BASE_PATH$_db_backup_tmp_file
		fi 
		echo "[size] [<path> / <name>] :"
		ls -sh "$GIT_BACKUP_BASE_PATH$_db_backup_file"
		echo ""
		echo "*******END OF BACKUP $i *********"
	fi
done
