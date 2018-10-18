# Copyright (c) 2018, Toby Slight. All rights reserved.
# ISC License (ISCL) - see LICENSE file for details.

import os
import sys
from yorn import ask

chars = ["\\", "/", "\"", ":", "<", ">", "^", "|", "*", "?", "+"]


def replace_chars(name):
    """
    iterate over & delete invalid characters in name.
    """

    for c in name:
        if c in chars or (isinstance(c, str) and sys.getsizeof(c) > 3):
            name = name.replace(c, "")

    name = name.strip()

    if name.endswith("."):
        name = name[:-1]  # remove last char

    return name


def rename_path(root, name, args):
    # found = re.search(re.escape("|".join(chars), name))
    # https://stackoverflow.com/a/5858943
    # any + generator is more robust
    found = any(c in name for c in chars)
    if found:
        oldpath = os.path.join(root, name)
        newpath = os.path.join(root, replace_chars(name))
        if args.interactive:
            question = "Would you like to rename " + \
                oldpath + " to " + newpath + " ? "
            if ask(question):
                os.rename(oldpath, newpath)
        elif args.automate:
            print("RENAMING: {} to {}".format(oldpath, newpath))
            os.rename(oldpath, newpath)
        elif args.dry_run:
            print("TESTING: {} to {}".format(oldpath, newpath))
        elif args.quiet:
            os.rename(oldpath, newpath)
        elif args.find:
            print(oldpath)
