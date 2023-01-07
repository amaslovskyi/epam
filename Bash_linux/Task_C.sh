# !/bin/bash

# directory to backup

source="$1"

# path where backup will be stored

dest="$2/$(basename $source)"
latest_backup="${dest}_latest"
log_file="$3"

# Main fucntion that backups 2 replicas of source directory

# Latest backup will show the changes between the source

# second replica will contain source on that time

backup() {
    rsync -ai --delete $source $latest_backup
    rsync -a --delete $source "${dest}_$(date "+%d_%m_%Y_%H_%M")"
}

# Returns dictionary of directory/file as key with value of operation (create, update, delete)

changes_dict() {
    raw_array=("$@")
    len=${#raw_array[@]}
    echo "("
    for i in $(seq 1 2 $len); do
        key=${raw_array[$i]}
        value=${raw_array[(($i - 1))]}
        echo "[$key]='$value'"
    done
    echo ")"
}

log_backup() {
    # Using --dry-run to get output of changes to log
    dry_run=$(rsync -ai --dry-run --delete $source $latest_backup)
    string=$(echo $dry_run)
    # Spliting dry-run output to array
    IFS=' ' read -r -a array <<<"$string"
    # Converting array into dictionary
    declare -A changes=$(changes_dict "${array[@]}")
    for key in ${!changes[@]}; do
        if [[ -z $key ]]; then
            key_date=$(date -r $key "+%d-%m-%Y %H:%M:%S")
        else
            key_date=$(date "+%d-%m-%Y %H:%M:%S")
        fi
        # To log all changes implement switch-case
        case ${changes[$key]} in
        "cd+++++++++")
            echo "[$key_date] <CREATED> directory $key" >>$log_file
            ;;
        ">f+++++++++")
            echo "[$key_date] <CREATED> file $key" >>$log_file
            ;;
        ">f.st......")
            echo "[$key_date] <UPDATED> $key" >>$log_file
            ;;
        "*deleting")
            echo "[$(date "+%d-%m-%Y %H:%M:%S")] <DELETED> $key" >>$log_file
            ;;
        esac
    done
}

check_for_updates() {
    dry_run=$(rsync -ai --dry-run --delete $source $latest_backup)
    if [[ $dry_run != "" ]]; then
        log_backup
        backup
    fi
}
