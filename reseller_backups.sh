#!/usr/bin/python

# MUST WRITE FOR PYTHON 2.6.6

resolds = {}
# resolds structure = {'$resold_uname': '$resold_backup_paths'}
reseller = input("\nReseller username? ")
# Maybe ask "all resolds" or "some resolds"
# support usernames.txt or a list of usernames via stdin
# ./script.py usernames.txt
backup_type = input("\nBackup type? (daily/weekly/monthly)\nPress enter for most recent. \n\n")

if backup_type not in ('daily', 'weekly', 'monthly', ''):
    print("\nGive me a real backup type tho? ")
