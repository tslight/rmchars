#!/usr/bin/env bash

MOUNTS=()
ELCLIST="$HOME/.ELC.lst"

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
	    echo "Successfully created $dir"
	else
	    echo "Failed to create $dir"
	fi
    fi
}

mntelc () {
    local elc="$1" MNT="$2"

    if ! mount | grep -Eq "$elc.*$MNT"; then
	getshare "$elc"
	if mount -t smbfs "$SHARE" "$MNT" &> /dev/null; then
	    echo "Successfully mounted $elc at $MNT"
	else
	    echo "Failed to mount $elc at $MNT"
	fi
    else
	echo "$elc already mounted at $MNT"
    fi
}

main () {
    local args="$*" MNT

    getelcs
    getcreds

    for elc in "${ELCS[@]}"; do
	MNT="/Volumes/ELCS/$elc"
	MOUNTS+=("$MNT")

	chkdir "$MNT"
	mntelc "$elc" "$MNT"
    done

    for mnt in "${MOUNTS[@]}"; do
	rmchars "$args" "$mnt"
    done
}

main "$@"
