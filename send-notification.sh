#!/bin/sh
# script to send a message to eliminate duplication
# by Chris D

while getopts "g:t:m:" option
do
    case $option in
        g)
            GOTIFY_ENDPOINT_WITH_API_KEY=$OPTARG ;;
        t)
            GOTIFY_TITLE=$OPTARG ;;
        m)
            GOTIFY_MESSAGE=$OPTARG ;;
    esac
done

curl $GOTIFY_ENDPOINT_WITH_API_KEY \
    -F "title=$GOTIFY_TITLE" \
    -F "message=$GOTIFY_MESSAGE" \
    -F "priority=5" \
    --output /dev/null --silent
