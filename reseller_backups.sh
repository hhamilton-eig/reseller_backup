#!/bin/bash

# Collects initial reseller info
read -ep "Reseller username? " reseller
reseller_home=$(find /home{1..11} -maxdepth 1 -name $reseller 2>/dev/null)
partition_usage=$(df -h | grep -oP "(\d+)(?=\%\s+\\${reseller_home%/*})")

# Checks that reseller's home partition usage is less than 50%
if (( $partition_usage > 70 )); then
    echo -e "\n${reseller_home%/*} is $partition_usage% full.
Please remove data from this partition before continuing.\n"
    exit
fi

<<<<<<< HEAD
# Array for resold users + backup paths
declare -A resolds

# Creates backup dir
if [[ ! -d $reseller_home/BackupNow ]]; then
    install -d -m 0755 -o $reseller -g $reseller $reseller_home/BackupNow
fi

# Finds all backups for given user of given type and puts in resolds array, defaults to all types
find_backups() {
    backup_paths=$(find /backup{1..11}{,.old}/{archived-backups,cpbackup}/"${2:-"{daily,weekly,monthly}"}"/${1} -maxdepth 0 2>/dev/null)
    if [[ -z $backup_paths ]]; then
    echo -e "No backups of the chosen type for ${resold_user}!\n"
    fi
    for backup in $backup_paths; do
        if [[ -n $backup ]]; then
            backup_date=$(date -r ${backup}/lastgenerated +%F)
            backup_path=${backup%$1*}
            backup="${backup_path} ${backup_date}\n"
            resolds["$1"]+="$backup"
        fi
    done
}

# Asks for most recent backup
read -ep "Do you want the most recent backup(s)? (yY/nN) " timeline
if [[ $timeline == [yY] ]]; then
    if [[ -z $1 ]]; then
        for resold_user in $(awk -F':' -v var="$reseller" '$5 ~ var {if($9){print $9}}' /var/cpanel/accounting.log); do
            find_backups $resold_user
        done
    else
        for resold_user in $(cat $1); do
            find_backups $resold_user
        done
    fi
    for resold_user in "${!resolds[@]}"; do
        if [[ -s ${reseller_home}/BackupNow/${resold_user}.tar.gz ]]; then
            echo "${reseller_home}/BackupNow/${resold_user}.tar.gz exists, skipping.."
        else
            resolds["$resold_user"]="$(echo -e "${resolds["$resold_user"]}" | sort -k2 | tail -1 | cut -d' ' -f1)"
            tar -C "${resolds["$resold_user"]}" -cf $reseller_home/BackupNow/$resold_user.tar.gz $resold_user
        fi
    done
else

# Makes backups if $backup_type provided
    read -ep "Backup type? (daily/weekly/monthly) " backup_type
    if [[ -z $1 ]]; then
        for resold_user in $(awk -F':' -v var="$reseller" '$5 ~ var {if($9){print $9}}' /var/cpanel/accounting.log); do
            find_backups $resold_user $backup_type
        done
    else
        for resold_user in $(cat $1); do
            find_backups $resold_user $backup_type
        done
    fi
    for resold_user in "${!resolds[@]}"; do
        if [[ -s ${reseller_home}/BackupNow/${resold_user}.tar.gz ]]; then
            echo "${reseller_home}/BackupNow/${resold_user}.tar.gz exists, skipping.."
        else
            resolds["$resold_user"]="$(echo -e "${resolds["$resold_user"]}" | sort -k2 | tail -1 | cut -d' ' -f1)"
            tar -C "${resolds["$resold_user"]}" -cf $reseller_home/BackupNow/$resold_user.tar.gz $resold_user
        fi
    done
fi
=======
# Creates backup dir

if [[ ! -d $reseller_home/BackupNow ]]; then
    install -d -m 0755 -o $reseller -g $reseller $reseller_home/BackupNow
fi

# Gets resold usernames from accounting log
# Include logic for if {daily,weekly,monthly} does not exist, but another does
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

# Creates tar.gz for each resold user in $reseller_home/BackupNow

for resold_user in "${!resolds[@]}"; do
    if [[ -f $reseller_home/BackupNow/$resold_user.tar.gz ]]; then
        echo "$reseller_home/BackupNow/$resold_user.tar.gz exists, skipping.."
    else
        tar -C "${resolds["$resold_user"]}" -cf $reseller_home/BackupNow/$resold_user.tar.gz $resold_user
    fi
done

# Fixes ownership of archives
>>>>>>> master

chown -R $reseller. $reseller_home/BackupNow
