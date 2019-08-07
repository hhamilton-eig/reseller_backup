read -p "Reseller: " reseller
for user in $( cat ./usernames ); do
echo "$user"
unset path 
path="$( sudo ls /backup{1..8}{,.old}/{archived-backups,cpbackup}/daily/"$user"/lastgenerated 2>/dev/null )"
path="${path%/*/*}/"
echo
if sudo [ -d "$path" ]; then
echo "tar -C "$path" -czvf /home/"$reseller"/BackupNow/"$user".tar.gz "$user"" >> ./tar_resold.sh
fi
done
chmod u+x ./tar_resold.sh
sed -i '/ \/$/d' ./tar_resold.sh
archives=( $( egrep -o "/home/.*.tar.gz" ./tar_resold.sh ) )
sudo mkdir /home/"$reseller"/BackupNow
sudo chown "$reseller":"$reseller" /home/"$reseller"/BackupNow
for archive in "${archives[@]}"; do
echo "chown "$reseller":"$reseller" "$archive"" >> ./tar_resold.sh
done
cat ./tar_resold.sh
