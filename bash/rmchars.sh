#!/usr/bin/env bash

# Define colors to be used when echoing output
readonly NC=$(tput sgr0);
readonly BLACK=$(tput setaf 0);
readonly RED=$(tput setaf 1);
readonly GREEN=$(tput setaf 2);
readonly YELLOW=$(tput setaf 3);
readonly BLUE=$(tput setaf 4);
readonly MAGENTA=$(tput setaf 5);
readonly CYAN=$(tput setaf 6);
readonly WHITE=$(tput setaf 7);

readonly CHARS=("\\" "/" "\"" ":" "<" ">" "\\^" "|" "*" "?" "+"); # escape backslash and quote
readonly LOG="$HOME/$(basename "$0")-$(date '+%Y-%m-%d').log"

# function that echos help page.
usage () {
    echo "
$(basename "$0") [OPTION] [DIRECTORY]

This script must run with one of the following options.

Options:
  -a, --ask          Ask before renaming each file.
  -l, --log	     Re-direct all output to logfile. Implies --yes.
  -t, --test         Display simulation of what will happen.
  -y, --yes          Rename all files without asking.
  -h, --help         Display this help and exit.

This script also takes a directory path as a second argument.

It searches all file and directory names for illegal characters and
renames them if found.

Please pass this command a directory to operate on.

Example:

$(basename "$0") -a /path/to/my/directory
"
}

# function that checks if argument variable is set, and then whether
# or not it's a valid directory.
checkdir () {
    local dir="$1"

    if [ ! -z "$dir" ]; then
	if [ -d "$dir" ]; then
	    return 0;
	else
	    echo;
	    echo "${RED}INVALID DIRECTORY.${NC}";
	    return 1;
	fi
    else
	return 1;
    fi
}

# function to read in an answer from the user. keep looping until user
# enters valid answer.  returns 0 for yes, 1 for no or quit, and an
# error message for anything else (before re-looping)
ask () {
    local question="$1" ans

    while :; do
	read -n 1 -rep "$question" ans;
	case "$ans" in
	    [yY]*)
		return 0
		;;
	    [nN]*)
		return 1
		;;
	    [qQ]*)
		exit 1
		;;
	    *)
		echo "${RED}You must enter either y or n to continue.${NC}";
		echo "${RED}You can also enter q to quit this .${NC}";
		;;
	esac;
    done
}

# Main function that takes a directory, a file type char and a flag
# char as arguments. The function substitutes in the directory as the
# directory to operate find on, the file type arg as a -type arg to
# find and the flag as an option to ask, automate or test the running
# of the script.
rmchars () {
    # Can't make an array of find results to loop over, because the
    # array will split the array on any spaces or any other IFS
    # (Internal Field Separator) characters. Therefore our paths will
    # be destroyed and the function will fails spectacularly!
    #
    # So instead we pipe the results of the find output (and
    # subsequent pipes) into a while loop that changes the Internal
    # Field Separator to nil, and reads in each line, instead of each
    # element of an array, splitting on space.
    #
    # Basically we are replacing word based iteration with line based
    # one by using a pipe instead of an array and manipulating the
    # IFS.
    #
    # Setting the IFS to nil also means that trailing spaces are kept
    # in our output. They would be destroyed otherwise.
    #
    # We need to use the -r flag with read to keep any backslashes in
    # the path as normally they would be seen as an escape character
    # and removed.
    #
    # find's printf argument is used to label our output with
    # directory tree depth. We number each entry using the %d option
    # (file depth in the directory tree), then %p to print the path,
    # and a \newline to break.
    #
    # We then pipe these results to sort to get a nice hierarchical
    # output, which we then need to reverse, with tac, get the longest
    # path at the top of our results.
    #
    # Finally we pipe to sed to get rid of the directory depth
    # numbering.
    local path="$1" type="$2" opt="$3" oldbase newbase dir c f

    find "$path" -type "$type" -printf "%d %p\\n" | sort -n | tac | sed 's/^[0-9]* //'|\
	while IFS= read -r f; do

	    oldbase=$(basename "$f");
	    newbase=$(basename "$f");
	    dir=$(dirname "$f");

	    # Loop through all invalid chars defined in global variable.
	    for c in "${CHARS[@]}"; do
		# Backslashes are hard, so we need an extra
		# conditional to find them with grep's -F
		# (--fixed-strings - interpret string literally) flag
		# and double escape them when piping to sed.
		if [ "$c" == "\\" ]; then
		    if echo "$newbase" | grep -q -F "$c"; then
			# newbase=$(echo "$newbase" | sed "s/\\$c//g");
			newbase=${newbase//\\"$c"/}
		    fi
		else
		    # We need to always quote the element variable
		    # call, as parameter and filename expansion does
		    # funny things..
		    if echo "$newbase" | grep -q "$c"; then
			# newbase=$(echo "$newbase" | sed "s/$c//g");
			newbase=${newbase//"$c"/}
		    fi
		fi
	    done

	    # Now we search for leading or trailing spaces or trailing
	    # dots. There's no way to add this to our char array as
	    # egrep and sed use a different regex engine :-(. Maybe
	    # awk could do be used instead...
	    #
	    # we also need to loop until the search condition is nil,
	    # to catch the case where we have spaces followed by dots,
	    # or visa versa
	    while echo "$newbase" | grep -Eq "^+ | +$|\\.+$"; do
		newbase=$(echo "$newbase" | sed 's/^[ \t]*//;s/[ \t]*$//;s/\.*$//');
	    done

	    # If any invalid chars were found our newbase variable
	    # will be changed. If it's not we don't need to do
	    # anything.
	    if [ "$oldbase" != "$newbase" ]; then

		new="$dir/$newbase"

		# check that the new file or directory name doesn't
		# already exist and if it does append a number to it.
		if [ -e "$new" ]; then
		    i=0;
		    while [ -e "$new-$i" ]; do
			# let i++;
			((i++))
		    done
		    new="$new-$i";
		fi

		case "$opt" in
		    a)
			question="Do you want to rename ${GREEN}$f${NC} to ${YELLOW}$new${NC}? "
			# One downside to piping find into a while
			# loop with read, is that inside the loop,
			# stdin is now coming from the pipe, and
			# commands that we execute inside the loop,
			# that expect a normal stdin, will misbehave.
			#
			# Therefore we need to redirect any further
			# calls to read to /dev/tty, so that our read
			# subshell can be correctly interpreted.
			ask "$question" < /dev/tty && mv "$f" "$new"
			;;
		    l)
			mv -v "$f" "$new" >> "$LOG" # pipe stdout & stderr to logfile
			;;
		    t)
			echo "Renaming ${GREEN}$f${NC} to ${YELLOW}$new${NC}"
			;;
		    y)
			echo "Renaming ${GREEN}$f${NC} to ${YELLOW}$new${NC}"
			mv "$f" "$new"
			;;
		esac
	    fi
	done
}

main () {
    local opt="$1" dir="$2"

    case "$opt" in
	-a|--ask)
	    if checkdir "$dir"; then
		rmchars "$dir" "f" "a"
		rmchars "$dir" "d" "a"
	    else
		usage;
		exit 1
	    fi
	    ;;
	-l|--log)
	    if checkdir "$dir"; then
		echo "${CYAN}Re-directing $(basename "$0") output to $LOG${NC}";
		echo >> "$LOG";
		echo "TIMESTAMP: $(date '+%H:%M:%S - %A %d %B %Y')" >> "$LOG";
		echo >> "$LOG";
		rmchars "$dir" "f" "l";
		rmchars "$dir" "d" "l";
	    else
		usage;
		exit 1
	    fi
	    ;;
	-t|--test)
	    if checkdir "$dir"; then
		echo "${CYAN}Running $(basename "$0") simulation. No files will be changed.${NC}";
		rmchars "$dir" "f" "t";
		rmchars "$dir" "d" "t";
		echo "${CYAN}$(basename "$0") simulation complete.${NC}";
	    else
		usage;
		exit 1
	    fi
	    ;;
	-y|--yes)
	    if checkdir "$dir"; then
		rmchars "$dir" "f" "y";
		rmchars "$dir" "d" "y";
	    else
		usage;
		exit 1
	    fi
	    ;;
	-h|--help)
	    usage
	    exit 0
	    ;;
	*)
	    usage
	    exit 1
	    ;;
    esac
}

main "$@"
