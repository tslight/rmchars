#!/usr/bin/env bash

CHARS=("\\" "/" "\"" ":" "<" ">" "\\^" "|" "*" "?" "+") # escape backslash and quote
NAMES=()

mknames () {
    name="test"
    for i in {0..9}; do
	newname="${name}$i"
	for c in "${CHARS[@]}"; do
	    newname="$newname $c"
	done
    NAMES+=("$newname")
    done
}

main () {
    for n in "${NAMES[@]}"; do
	# set -f
	# echo
	# echo "$n"
	# echo
	mkdir "$n"
	touch "$n"
	# set +f
    done
}

mknames
main
