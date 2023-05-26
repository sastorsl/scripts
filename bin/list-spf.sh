#!/bin/bash
# list-spf.sh
# 27.04.2020, Stein Arne Storslett, list all IP-adresses in a domain name's SPF record(s)
# 

usage () {
  echo "usage: list-spf.sh [<userid>@|@]<domain-name>"
  exit 1
}

logerr () {
    if [ -n "$VERBOSE" ]
    then
        exec 6>&1  # Link file descriptor #6 with stdout. Saves stdout.
        exec >&2   # Send stdout to stderr
        echo "$@"
        exec 1>&6 6>&- # Restore stdout and close file descriptor #6.
    fi
}

[[ $# =~ (^[^12]$) ]] && usage

DN="$1"
case "$2" in
    -v|--verbose) VERBOSE=true ;;
esac

# Strip any leading @ / user@
DN=$(echo "$1" | sed 's/^.*@//')

RET=$(host -t MX $DN 2>&1)

# Abort if this isn't a valid DNS record with a valid MX record.
if [[ "$RET" == *"has no MX record"* ]]
then
    echo "Hostname \"$DN\" is not a mail domain as it has no MX record"
    exit 1
fi

# Check if we actually have an SPF record.
# Output will be used later.
RET=$(host -t txt "$DN")
logerr $RET

if [[ "$RET" != *"v=spf1"* ]]
then
    echo "Hostname \"$DN\" does not have an SPF record"
    exit 99
fi

get_ip4_from_spf () {
    local IN=$1
    if [[ "$IN" == *"v=spf1"* ]]
    then
        for ITEM in $IN
        do
            ITEM=$(echo "$ITEM" | tr -d \")
            logerr "Item: $ITEM"
            if [[ "$ITEM" == "ip4:"* ]]
            then
                OUTPUT="$OUTPUT\n$ITEM"
                logerr "Output: $OUTPUT"
            fi
            if [[ "$ITEM" == "ip6:"* ]]
            then
                OUTPUT="$OUTPUT\n$ITEM"
                logerr "Output: $OUTPUT"
            fi
            if [ "$ITEM" = "-all" ]
            then
                OUTPUT="$OUTPUT\n$ITEM"
                logerr "Output: $OUTPUT"
            fi
            if [[ "$ITEM" == "include:"* ]]
            then
                logerr "Include: $ITEM"
                OUTPUT="$OUTPUT\n# $ITEM"
                get_ip4_from_spf "$(host -t txt ${ITEM#include:})"
            fi
        done
        logerr "in-func-output: $OUTPUT"

    else
        logerr "Nothing found in $IN"
    fi
}

OUTPUT=""
get_ip4_from_spf "$RET"
OUTPUT=$(echo -e "$OUTPUT" | sed -e :a -e '/./,$!d;/^\n*$/{$d;N;};/\n$/ba')
echo "# SPF record for $DN:"
echo -e "$OUTPUT"
