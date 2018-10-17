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
    local elc="$1"
    local mntpt="$2"

    if ! mount | grep -Eq "$elc.*$mntpt"; then
	if mount -t smbfs "//${USER}:${PASS}@${elc}/ELC/Shared" "$mntpt"; then
	    echo "Successfully mounted $elc at $mntpt"
	else
	    echo "Failed to mount $elc at $mntpt"
	fi
    else
	echo "$elc already mounted at $mntpt"
    fi
}

main () {
    local mntpt

    getelcs
    getcreds

    for elc in "${ELCS[@]}"; do
	mntpt="/Volumes/ELCS/$elc"
	MOUNTS+=('mntpt')

	chkdir "$mntpt"
	mntelc "$elc" "$mntpt"
    done

    for mnt in "${MOUNTS[@]}"; do
	rmchars -f "$mnt"
    done
}

main
