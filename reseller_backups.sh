#!/bin/bash

# Collects initial reseller info
read -ep "Reseller username? " reseller
reseller_home=$(find /home{1..11} -maxdepth 1 -name $reseller 2>/dev/null)
partition_usage=$(df -h | grep -oP "(\d+)(?=\%\s+\\${reseller_home%/*})")

# Array for resold users + backup paths
declare -A resolds

# Finds all backups for resold user fed to function and associates with user in resolds array
find_backups() {
backup_paths=$(find /backup{1..11}{,.old}/{archived-backups,cpbackup}/{daily,weekly,monthly}/$1 -maxdepth 0 2>/dev/null)
for backup in $backup_paths; do
if [[ -n $backup ]]; then
backup_date=$(date -r ${backup}/lastgenerated +%F)
backup_path=${backup%$1*}
backup="${backup_path} ${backup_date}\n"
resolds["$1"]+="$backup"
fi
done
}
# Finds backups depending on whether list was provided
if [[ -z $1 ]]; then
for resold_user in $(awk -F':' -v var="$reseller" '$5 ~ var {if($9){print $9}}' /var/cpanel/accounting.log); do
    find_backups $resold_user
done

else

for resold_user in $(cat $1); do
    find_backups $resold_user
done

fi

# Asks for most recent backup or backup type
read -ep "Do you want the most recent backup(s)? (yY/nN) " timeline
  if [[ $timeline == [yY] ]]; then
    for resold_user in "${!resolds[@]}"; do
      recent_backup="$(echo -e "${resolds["$resold_user"]}" | sort -k2 | tail -1)"
      echo -e "$recent_backup"
done
# find most recent backup and archive it
# Check backup dates
#else
#  read -ep "Backup type? (daily/weekly/monthly) " backup_type
fi
