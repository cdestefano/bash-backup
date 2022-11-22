#!/bin/sh
# script to output all backups on a remote server
# by Chris D


while getopts "p:s:r:l:i:g:" option
do
    case $option in
        p)
            BORG_PASSPHRASE=$OPTARG ;;
        s)
            BORG_SSH_CONFIG_NAME=$OPTARG ;;
        r)
            BORG_REMOTE_DIRECTORY_PATH=$OPTARG ;;
        l)
            FULL_LOG_DIRECTORY=$OPTARG ;;
        i)
            GOTIFY_SERVERNAME=$OPTARG ;;
        g)
            GOTIFY_ENDPOINT_WITH_API_KEY=$OPTARG ;;
    esac
done

# ------------- <><><><> DON'T MODIFY BELOW THIS LINE IF YOU WANT TO USE OUT THE BOX CONFIG <><><><> ------------- #

export BORG_PASSPHRASE=$BORG_PASSPHRASE

borg list \
    $BORG_SSH_CONFIG_NAME:$BORG_REMOTE_DIRECTORY_PATH \
    2>&1 | tee -a "$FULL_LOG_DIRECTORY/all-archives.txt"

MESSAGE="$(cat $FULL_LOG_DIRECTORY/all-archives.txt)"

./send-notification.sh \
    -g $GOTIFY_ENDPOINT_WITH_API_KEY \
    -t "List of All Backups" \
    -m "$MESSAGE"
