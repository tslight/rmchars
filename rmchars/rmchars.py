# Copyright (c) 2018, Toby Slight. All rights reserved.
# ISC License (ISCL) - see LICENSE file for details.
"""
Module that carries out the heavy lifting.
"""
import os
import unicodedata
from yorn import ask

CHARS = ["\\", "/", "\"", ":", "<", ">", "^", "|", "*", "?"]
# http://www.unicode.org/reports/tr44/#GC_Values_Table
UCHARS = ["Lo", "So", "Cc"]  # Other_Letter, Other_Symbol, Control_Character


def replace_chars(name):
    """
    iterate over & delete invalid characters in name.
    """
    for char in name:
        if char in CHARS:
            name = name.replace(char, "")
        # https://stackoverflow.com/questions/4324790/removing-control-characters-from-a-string-in-python
        if unicodedata.category(char) in UCHARS:
            name = name.replace(char, "")
        name = name.strip()  # remove leading and trailing spaces
        if name.endswith("."):
            name = name[:-1]  # remove last char
    return name


def is_invalid(name, invalid=False):
    """
    Checks if any of invalid chars are present in name of the node and returns
    true if they are.
    """
    # found = re.search(re.escape("|".join(chars), name))
    # https://stackoverflow.com/a/5858943
    # any + generator is more robust
    # char_found = any(c in name for c in chars)
    for char in name:
        if char in CHARS or unicodedata.category(char) in UCHARS:
            invalid = True
    return invalid


def rename_path(root, name, args):
    """
    Use is_invalid to check if node name contains invalid chars, and if true use
    replace_chars to create a new node name and join it to the full path.

    Finally, check args on how to proceed.
    """
    if is_invalid(name):
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
