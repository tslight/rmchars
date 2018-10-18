#!/usr/bin/env bash

DIR=$(dirname "$0")
LOG="$DIR/rmchars.log"
ELCLIST="$HOME/.ELC.lst"
MOUNTS=()

getelcs () {
    # https://stackoverflow.com/a/11394045
    IFS=$'\n' read -d '' -r -a ELCS < "$ELCLIST"
}

getcreds () {
    read -re -p "Enter your Egnyte Admin username: " USER
    read -res -p "Enter you Egnyte Admin password: " PASS
    # USER=$(printf '%q' "$user") # escape special bash chars
    # PASS=$(printf '%q' "$pass") # escape special bash chars
}

getshare () {
    local elc="$1" share

    share="//${USER}:${PASS}@${elc}/ELC"
    SHARE="${share// /%20}"
}

chkdir () {
    local dir="$1"

    if [[ ! -d "$dir" ]]; then
	if mkdir -p "$dir"; then
	    echo "Successfully created $dir" | tee -a "$LOG"
	else
	    echo "Failed to create $dir" | tee -a "$LOG"
	fi
    fi
}

mntelc () {
    local elc="$1" MNT="$2"

    if ! mount | grep -Eq "$elc.*$MNT"; then
	getshare "$elc"
	if mount -t smbfs "$SHARE" "$MNT" &>> "$LOG"; then
	    echo "Successfully mounted $elc at $MNT" | tee -a "$LOG"
	else
	    echo "Failed to mount $elc at $MNT" | tee -a "$LOG"
	fi
    else
	echo "$elc already mounted at $MNT" | tee -a "$LOG"
    fi
}

main () {
    local args="$*" MNT

    getelcs
    getcreds

    for elc in "${ELCS[@]}"; do
	MNT="/Volumes/ELCS/$elc"
	chkdir "$MNT"
	mntelc "$elc" "$MNT"
	rmchars "$args" "$MNT" | tee -a "$LOG"
    done
}

main "$@"
