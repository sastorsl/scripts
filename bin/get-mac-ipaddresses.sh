#!/usr/bin/env bash
# Get the IP address of all network interfaces _which have an IP_
# Print the interface name, IP, and "star" the _default_ interface
#

function do_print () {
  # Just pretty print stuff
  [ "${INF}" = "${DEFAULT_ROUTE}" ] && DEF=" (*)"
  printf "%-4s %s\n" ${INF} "${IPADDR}${DEF}"
  DEF=""
}

if which ipconfig >/dev/null 2>&1
then
  IFLIST=$(ipconfig getiflist 2>/dev/null)

  if [ -n "${IFLIST}" ]
  then
    DEFAULT_ROUTE=$(route -n get default | awk '$1 == "interface:" { print $2 }')
    for INF in $(ipconfig getiflist)
    do
      IPADDR=$(ipconfig getifaddr ${INF})
      if [ -n "${IPADDR}" ]
      then
        do_print
      fi
    done
  fi
elif which ip >/dev/null 2>&1
then
  DEFAULT_ROUTE=$(ip route get 8.8.8.8 | grep -Po '(?<=(dev ))(\S+)')
  while read INF IPADDR
  do
    do_print
  done < <(ip -o addr | awk '$2 !~ /^lo/ { sub(/\/.+/,"",$4) ; print $2, $4 }')
else
  echo "ERROR This script is built for some tools. Please fix for this platform: $(uname -a)"
fi
