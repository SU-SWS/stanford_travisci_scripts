#!/usr/bin/env bash

if [ -z "$1" ]
then
    echo "Usage: $0 <glob_path>"
    exit 1
fi

if [ -z "$IMGUR_API_KEY" ]
then
    echo "To use screenshots uploader, it is essential to set up a variable with imgur api key"
    echo "Run:"
    echo "$ export IMGUR_API_KEY=\"your api key\""
    exit 1
fi

echo "Uploading screenshots..."

for image in $1
do
    if [ ! -e "$image" ]
    then
        break
    fi
    url=`curl -X POST "http://imgur.com/upload" \
      -H "Referer: http://imgur.com/upload" \
      -F "Filedata=@$image"`
    short_url=$(echo $url | jq -r '.data' | jq -r '.hashes' | sed 's/[^[:alnum:]]\+//g' | tr -d '\n' )
    echo "$image - http://imgur.com/$short_url"

done
