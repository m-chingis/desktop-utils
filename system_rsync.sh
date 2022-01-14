#!/bin/bash
#
# Name    : system_rsync.sh 
# Author  : Shyngys Meirman aka sm42
# Date    : 20221013
# Purpose : A script to perform incremental backups using rsync
# Credits : Egidio Docile https://linuxconfig.org/how-to-create-incremental-backups-using-rsync-on-linux
#           reddit.com/user/Snickasaurus/ https://www.reddit.com/r/bash/comments/7yhqkt/rsync_include_from_array_list_within_script_not/

clear

set -o errexit
set -o nounset
set -o pipefail

#readonly SOURCE_DIR="$HOME/work"
#readonly BACKUP_DIR="$HOME/work_bak"
readonly SOURCE_DIR="/"
readonly BACKUP_DIR="/media/sm/linux_ext4/rsync_backups"
readonly DATETIME="$(date '+%Y-%m-%d_%H%M%S')"
readonly BACKUP_PATH="$BACKUP_DIR/$DATETIME"
readonly LATEST_LINK="$BACKUP_DIR/latest"
#readonly LOGFILE="$HOME/work/rSync.log"

# The list of excluded dirs
declare -a DIRS2EXCLUDE=(
    '.cache'
    "/lost+found"
    "/mnt"
    "/media"
    "/dev"  # contents will be dumped via tree and ls -lR
    "/proc" # contents will be dumped via tree and ls -lR
    "/run"
    "/sys"
    "/tmp"
)
echo "Source dir: $SOURCE_DIR"
echo "Excluded directories: "
for dir in ${DIRS2EXCLUDE[@]}; do
  echo "  $dir"
done

# Logging
# exec 3>&1 4>&2 
# trap 'exec 2>&4 1>&3' 0 1 2 3
# exec 1>>"$LOGFILE" 2>&1

# Backup starting.
echo " "
echo "=====Starting @ "$(date "+%H:%M:%S  %Y/%m/%d")" ====="
echo " "
echo " "

mkdir -p "${BACKUP_DIR}"

rsync -aH --delete \
  "${SOURCE_DIR}/" \
  "${BACKUP_PATH}" \
  --link-dest "${LATEST_LINK}" \
  --exclude-from=<(printf '%s\n' "${DIRS2EXCLUDE[@]}") 

rm -rf "${LATEST_LINK}"
ln -s "${BACKUP_PATH}" "${LATEST_LINK}"

# tree and ls dumps
tree /dev > $BACKUP_PATH/dev.tree
tree /proc > $BACKUP_PATH/proc.tree
tree /sys > $BACKUP_PATH/sys.tree
ls -lR /dev > $BACKUP_PATH/dev.ls
ls -lR /proc > $BACKUP_PATH/proc.ls
ls -lR /sys > $BACKUP_PATH/sys.ls

  # Backup completed.
echo " "
echo " "
echo "=====Completed @ "$(date "+%H:%M:%S  %Y/%m/%d")" ====="
