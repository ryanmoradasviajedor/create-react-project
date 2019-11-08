#!/usr/bin/env bash
if [[ -z "$1" ]]; then
    echo "Please specify a target directory or file."
    echo "Example: $0 plugins/spycetek/utils"
    exit 1
fi

./vendor/bin/phpcs --colors --standard=./phpcs.xml --ignore=*/assets/*, --extensions=php $1
