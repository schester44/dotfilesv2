#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title PRDB
# @raycast.mode silent
# @raycast.argument1 { "type": "text", "placeholder": "PR#" }

# Optional parameters:
# @raycast.packageName PRDB

# Documentation:
# @raycast.description Quickly open PR databases
# @raycast.author Steve
# @raycast.authorURL steve@obieinsurance.com 

is_number() {
  re='^[0-9]+$'
  if [[ $1 =~ $re ]]; then
    return 0
  else
    return 1
  fi
}

if [[ -z $1 ]]; then
  echo "Usage: $0 <pr-number or app name>"
  exit 1
fi

arg=$1
appname=$arg

if is_number "$arg"; then
  appname="obie-rm-review-pr-$arg"
else
  appname=$arg
fi

url=$(heroku config:get DATABASE_URL --app $appname)

if [[ -z $url ]]; then
  echo "No app found with name $appname"
  exit 1
fi

if [[ $2 == "-p" ]]; then
 echo $url
else
  echo "Opening"
  open $url
fi
