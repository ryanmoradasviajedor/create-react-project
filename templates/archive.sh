#!/usr/bin/env bash

BASE_FILENAME="octo"
USAGE_MESSAGE="Usage: $0 <version_name>"
USAGE_EXAMPLE="Example: $0 123"

if [ $# -lt 1 ]; then
    echo -e $USAGE_MESSAGE 1>&2
    echo -e $USAGE_EXAMPLE 1>&2
    exit 1
fi

FILENAME=$BASE_FILENAME-v$1.zip
git-archive-all --prefix='' $FILENAME
echo "Created $FILENAME"

git tag v$1

