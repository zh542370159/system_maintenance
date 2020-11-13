#!/usr/bin/env bash
######################### Parameters ##########################################
id="archive_cold"
repository="/archive"
storage="/archive_cold/Backup_duplicacy"
filters=("")
DUPLICACY_PASSWORD="b206shalab"
broadcast="TRUE"
###############################################################################

duplicacy &>/dev/null
[ $? -eq 127 ] && {
    echo -e "Cannot find the command duplicacy.\n"
    exit 1
}

if [[ ! -d $duplicacy_repo ]]; then
    echo -e "ERROR! Cannot find the repository directory: $duplicacy_repo"
    exit 1
fi
cd 

export DUPLICACY_PASSWORD=$DUPLICACY_PASSWORD
duplicacy -r $restic_repo check &>/dev/null
if [[ $? != 0 ]]; then
    echo -e "ERROR! restic check failed for the repository directory: $restic_repo"
    exit 1
fi

####### Start preocessing #######
logfile=$restic_repo/AllBackup.log

SECONDS=0
echo -e "****************** Start Backup ******************" &>>$logfile
echo -e ">>> Backup start at $(date +'%Y-%m-%d %H:%M:%S')" &>>$logfile
echo -e ">>> Backup targets: ${backup_arr[*]}" &>>$logfile
echo -e ">>> Backup targets excluding: ${exclude_arr[*]}\n" &>>$logfile

echo -e "*** Make a restic backup for the targets" &>>$logfile
exclude_par=$(printf -- "%s," "${exclude_arr[@]}")
cmd="restic -r $restic_repo backup --quiet --exclude={${exclude_par%,}} ${backup_arr[*]} "

echo -e "*** Run restic command: \n$cmd" &>>$logfile
#echo "$cmd"
eval $cmd &>>$logfile

if [[ $? != 0 ]]; then
    echo -e "Backup failed!\n" &>>$logfile
    ELAPSED="Elapsed: $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
    echo -e "$ELAPSED" &>>$logfile
    echo -e "****************** Backup failed ******************\n\n\n" &>>$logfile
    if [[ $broadcast == "TRUE" ]]; then
        echo -e "\n>>> Backup_targz: $(date +'%Y-%m-%d %H:%M:%S') Backup failed! Please check the log: $restic_repo/AllBackup.log\n" >>/etc/motd
    fi
    exit 1
else
    echo -e "Backup completed.\n" &>>$logfile
    ELAPSED="Elapsed: $(($SECONDS / 3600))hrs $((($SECONDS / 60) % 60))min $(($SECONDS % 60))sec"
    echo -e "$ELAPSED" &>>$logfile
    echo -e "****************** Backup successfully completed ******************\n\n\n" &>>$logfile
fi
