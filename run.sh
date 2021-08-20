#!/usr/bin/env bash

ELCS=()
ELCLIST="$HOME/.ELC.lst"
DIR=$(dirname "$0")
LOG="$DIR/rmchars-$(date +%Y-%m-%d.%H).log"

chkroot() {
    if [ "$(id -u)" -ne 0 ]; then
	echo "This script must be run as root or with sudo."
	exit 1
    fi
}

chkpy () {
    if ! command -v rmchars &> /dev/null; then
	echo "rmchars not installed. Attempting to install..." | tee -a "$LOG"
	if command -v pip3 &> /dev/null; then
	    if pip3 install rmchars &> "$LOG"; then
		echo "Successfully installed rmchars." | tee -a "$LOG"
	    else
		echo "Failed to install rmchars." | tee -a "$LOG"
		exit 1
	    fi
	else
	    echo "No pip3... Is python3 installed?" | tee -a "$LOG"
	    exit 1
	fi
    fi
}

getelcs () {
    # https://stackoverflow.com/a/11394045
    # IFS=$"\n" read -d "" -r -a ELCS < "$ELCLIST"
    # https://stackoverflow.com/a/19219860
    while IFS=$"\n" read line; do
	if ! [[ "$line" =~ \#.* ]]; then
	    ELCS+=("$line")
	fi
    done < "$ELCLIST"
}

getcreds () {
    read -re -p "Enter your Egnyte Admin username: " USER
    read -res -p "Enter you Egnyte Admin password: " PASS; echo
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
    local elc="$1" mntpt="$2"

    if ! mount | grep -Eq "$elc.*$mntpt"; then
	getcreds
	getshare "$elc"
	if mount -t smbfs "$SHARE" "$mntpt" &>> "$LOG"; then
	    echo "Successfully mounted $elc at $mntpt" | tee -a "$LOG"
	else
	    echo "Failed to mount $elc at $mntpt" | tee -a "$LOG"
	fi
    else
	echo "$elc already mounted at $mntpt" | tee -a "$LOG"
    fi
}

main () {
    local args="$*" mntpt

    chkroot
    chkpy

    if [[ "$args" == "" ]]; then
	rmchars --help
	exit 1
    fi

    getelcs

    for elc in "${ELCS[@]}"; do
	mntpt="/Volumes/ELCS/$elc"
	chkdir "$mntpt"
	mntelc "$elc" "$mntpt"
	rmchars "$args" "$mntpt" | tee -a "$LOG"
    done
}

main "$@"
