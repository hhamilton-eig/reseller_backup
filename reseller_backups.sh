#!/bin/bash

# Sets up arrays and variables
declare -A resolds
read -ep "Reseller username? " reseller
read -ep "Backup type? (daily/weekly/monthly) " backup_type
reseller_home=$(find /home{1..11} -maxdepth 1 -name $reseller 2>/dev/null)
partition_usage=$(df -h | grep -oP "(\d+)(?=\%\s+\/home1)")

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

# Gets resold usernames from accounting log
# Include logic for if {daily,weekly,monthly} does not exist, but another does

if [[ -z $1 ]]; then

for resold_user in $(awk -F':' -v var="$reseller" '$5 ~ var {if($9){print $9}}' /var/cpanel/accounting.log); do
    backup_path=$(find /backup{1..11}{,.old}/{archived-backups,cpbackup}/$backup_type/$resold_user -maxdepth 0 2>/dev/null)
    backup_path=${backup_path%/*}
    if [[ -n $backup_path ]]; then
    resolds["$resold_user"]+="$backup_path"
    else
    echo -e "No $backup_type backups present for $resold_user, run the script again
using one of the other backup types if you need backups for this user"
    fi
done

else

for resold_user in $(cat $1); do
    backup_path=$(find /backup{1..11}{,.old}/{archived-backups,cpbackup}/$backup_type/$resold_user -maxdepth 0 2>/dev/null)
    backup_path=${backup_path%/*}
    if [[ -n $backup_path ]]; then
    resolds["$resold_user"]+="$backup_path"
    else
    echo -e "No $backup_type backups present for $resold_user, run the script again
using one of the other backup types if you need backups for this user"
    fi
done

fi


# Creates tar.gz for each resold user in $reseller_home/BackupNow

for resold_user in "${!resolds[@]}"; do
    if [[ -f $reseller_home/BackupNow/$resold_user.tar.gz ]]; then
        echo "$reseller_home/BackupNow/$resold_user.tar.gz exists, skipping.."
    else
        tar -C "${resolds["$resold_user"]}" -cf $reseller_home/BackupNow/$resold_user.tar.gz $resold_user
    fi
done

# Fixes ownership of archives

chown -R $reseller. $reseller_home/BackupNow
