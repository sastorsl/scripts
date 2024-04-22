#!/usr/bin/env bash

dumpIpForInterface()
{
  IT=$(ifconfig "$1") 
  if [[ "$IT" != *"status: active"* ]]; then
    return
  fi
  if [[ "$IT" != *" broadcast "* ]]; then
    return
  fi
  echo "$IT" | awk '/inet / && !/127.0.0.1/ {print $2}'
}

main()
{
  # snagged from here: https://superuser.com/a/627581/38941
  DEFAULT_ROUTE=$(route -n get 0.0.0.0 2>/dev/null | awk '$1 == "interface:" {print $2}')
  if [ -n "$DEFAULT_ROUTE" ]; then
    dumpIpForInterface "$DEFAULT_ROUTE"
  else
    for i in $(ipconfig getiflist)
    do 
      if [[ $i != *"vboxnet"* ]]; then
        dumpIpForInterface "$i"
      fi
    done
  fi
}

main
