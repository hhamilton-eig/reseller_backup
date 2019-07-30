declare -A resolds; read -ep "Reseller username? " reseller; read -ep "Backup type? (daily/weekly/monthly) " backup_type; reseller_home=$(find /home{1..11} -maxdepth 1 -name $reseller 2>/dev/null); partition_usage=$(df -h | grep -oP "(\d+)(?=\%\s+\/home1)"); if [[ $partition_usage > 70 ]]; then echo -e "\n${reseller_home%/*} is $partition_usage% full.\nPlease remove data from this partition before continuing.\n"; exit; fi; install -d -m 0755 -o $reseller -g $reseller $reseller_home/BackupNow; tar -cf $reseller_home/BackupNow/resold_backups.tar --files-from /dev/null; for resold_user in $(awk -F':' -v var=" $reseller" '$2 ~ var {print $1}' /etc/trueuserowners); do backup_path=$(find /backup{1..11}{,.old}/{archived-backups,cpbackup}/$backup_type/$resold_user -maxdepth 0 2>/dev/null); resolds["$resold_user"]+="$backup_path"; done; for resold_user in "${!resolds[@]}"; do tar -rf $reseller_home/BackupNow/resold_backups.tar "${resolds["$resold_user"]}"; done; chown $reseller. $reseller_home/BackupNow/resold_backups.tar; gzip $reseller_home/BackupNow/resold_backups.tar
