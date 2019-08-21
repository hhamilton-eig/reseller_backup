#!/bin/bash

# Collects initial reseller info
read -ep "Reseller username? " reseller
reseller_home=$(find /home{1..11} -maxdepth 1 -name $reseller 2>/dev/null)
partition_usage=$(df -h | grep -oP "(\d+)(?=\%\s+\\${reseller_home%/*})")

# Checks that reseller's home partition usage is less than 50%
if [[ $partition_usage > 70 ]]; then
    echo -e "\n${reseller_home%/*} is $partition_usage% full.
Please remove data from this partition before continuing.\n"
    exit
fi

# Creates backup dir
if [[ ! -d $reseller_home/BackupNow ]]; then
    install -d -m 0755 -o $reseller -g $reseller $reseller_home/BackupNow
fi

# Array for resold users + backup paths
declare -A resolds

# Finds all backups for resold user fed to function and associates with user in resolds array
find_backups() {
backup_paths=$(find /backup{1..11}{,.old}/{archived-backups,cpbackup}/{daily,weekly,monthly}/$1 -maxdepth 0 2>/dev/null)
for backup in $backup_paths; do
backup=${backup%$1*}
if [[ -n $backup ]]; then
resolds["$1"]+="$backup "
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
    for backup in "${resolds["$resold_user"]}"; do
    date -r ${backup}/${resold_user}/lastgenerated +%F

# find most recent backup and archive it
# Check backup dates
else
  read -ep "Backup type? (daily/weekly/monthly) " backup_type



# Creates tar.gz for each resold user in $reseller_home/BackupNow
for resold_user in "${!resolds[@]}"; do
    if [[ -s $reseller_home/BackupNow/$resold_user.tar.gz ]]; then
        echo "$reseller_home/BackupNow/$resold_user.tar.gz exists and is not empty, skipping.."
    else
        tar -C "${resolds["$resold_user"]}" -cf $reseller_home/BackupNow/$resold_user.tar.gz $resold_user
    fi
done

# Fixes ownership of archives
chown -R $reseller. $reseller_home/BackupNow
