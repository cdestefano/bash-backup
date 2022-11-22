#!/bin/sh
# script to backup a remote repo to borg
# by Chris D

# Ensure that you've created a remote borg repo. 

# Encryption password.

BORG_PASSPHRASE="EncryptionPassword"

BORG_SSH_CONFIG_NAME="ssh-borg-backup-test"

BORG_REMOTE_DIRECTORY_PATH="/path/to/where/you/want/to/store/the/repo"

BORG_ARCHIVE_NAME_PREFIX="archiveNameInstance"

BORG_BACKUP_HOST_FIRST_DIRECTORY_PATH="/directory/that/you/want/to/backup/on/the/host"
BORG_BACKUP_HOST_SECOND_DIRECTORY_PATH="/optionally/second/path"

DOCKER_COMPOSE_DIRECTORY_ONE="/home/chris/testDockerDir/compose/docker-compose.yml"
DOCKER_COMPOSE_DIRECTORY_SECOND="/home/chris/testDockerDir/compose/docker-compose.yml"

LOG_DIRECTORY="."

GOTIFY_SERVERNAME="TEST-SERVER"
GOTIFY_ENDPOINT_WITH_API_KEY="https://GOTIFY.domain-name.com/message?token=TOKEN_KEY"

# ------------- <><><><> DON'T MODIFY BELOW THIS LINE IF YOU WANT TO USE OUT THE BOX CONFIG <><><><> ------------- #

BORG_ARCHIVE_NAME_DATETIME=$(date "+%m-%d-%Y_%I_%M_%S")
BORG_ARCHIVE_NAME="$BORG_ARCHIVE_NAME_PREFIX"_"$BORG_ARCHIVE_NAME_DATETIME"

FULL_LOG_DIRECTORY="$LOG_DIRECTORY/$BORG_ARCHIVE_NAME"

mkdir $FULL_LOG_DIRECTORY

export BORG_PASSPHRASE=$BORG_PASSPHRASE

./send-notification.sh \
    -g $GOTIFY_ENDPOINT_WITH_API_KEY \
    -t "Backup starting: $GOTIFY_SERVERNAME" \
    -m "Archive: $BORG_ARCHIVE_NAME_DATETIME"

docker-compose -f "$DOCKER_COMPOSE_DIRECTORY_ONE" down
docker-compose -f "$DOCKER_COMPOSE_DIRECTORY_SECOND" down

docker ps | tee "$FULL_LOG_DIRECTORY/docker_stopped_containers.txt"

MESSAGE="$(cat $FULL_LOG_DIRECTORY/docker_stopped_containers.txt)"
./send-notification.sh \
    -g $GOTIFY_ENDPOINT_WITH_API_KEY \
    -t "Docker containers stopped: $GOTIFY_SERVERNAME" \
    -m "Containers: $MESSAGE"

borg create \
    --progress \
    --stats \
    $BORG_SSH_CONFIG_NAME:$BORG_REMOTE_DIRECTORY_PATH::$BORG_ARCHIVE_NAME \
    $BORG_BACKUP_HOST_FIRST_DIRECTORY_PATH \
    $BORG_BACKUP_HOST_SECOND_DIRECTORY_PATH \
    2>&1 | tee -a "$FULL_LOG_DIRECTORY/borg_create.txt"

docker-compose -f "$DOCKER_COMPOSE_DIRECTORY_ONE" up -d
docker-compose -f "$DOCKER_COMPOSE_DIRECTORY_SECOND" up -d

sleep 10 &
wait

docker-compose -f "$DOCKER_COMPOSE_DIRECTORY_SECOND" up -d

sleep 10 &
wait

MESSAGE="$(cat $FULL_LOG_DIRECTORY/borg_create.txt)"
./send-notification.sh \
    -g $GOTIFY_ENDPOINT_WITH_API_KEY \
    -t "Borg Backup completed: $GOTIFY_SERVERNAME" \
    -m "Containers: $MESSAGE"

docker ps | tee "$FULL_LOG_DIRECTORY/docker_started_containers.txt"

MESSAGE="$(cat $FULL_LOG_DIRECTORY/docker_started_containers.txt)"
./send-notification.sh \
    -g $GOTIFY_ENDPOINT_WITH_API_KEY \
    -t "Backup completed! $GOTIFY_SERVERNAME" \
    -m "Containers started: $MESSAGE"

