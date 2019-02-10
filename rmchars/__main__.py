"""
Copyright (c) 2018, Toby Slight. All rights reserved.
ISC License (ISCL) - see LICENSE file for details.
"""
import argparse
import os
from .actions import rename, interactive, dryrun
from .check import is_invalid, get_paths
from .create import create


def chkpath(path):
    """
    Checks for valid directory path.
    """
    if os.path.exists(path):
        if os.path.isdir(path):
            return path
        else:
            msg = "{0} is not a directory.".format(path)
    else:
        msg = "{0} does not exist.".format(path)
    raise argparse.ArgumentTypeError(msg)


def getargs():
    """
    Return a list of valid arguments. If no argument is given, default to $PWD.
    """
    parser = argparse.ArgumentParser(
        description='Remove invalid characters from a given path.')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("-i", "--interactive", action="store_true",
                       help="prompt before renaming each path")
    group.add_argument("-a", "--automate", action="store_true",
                       help="rename each path without prompting")
    group.add_argument("-t", "--dry_run", action="store_true",
                       help="preform a dry run to see what would be renamed")
    group.add_argument("-q", "--quiet", action="store_true",
                       help="run silently")
    group.add_argument("-c", "--create", action="store", type=int,
                       help="create test directories")
    parser.add_argument("path", type=chkpath, nargs='?',
                        default=".", help="a valid path")
    return parser.parse_args()


def process_args(root, name, args):
    """
    Get new and old paths then check how to process based on args.
    """
    if is_invalid(name):
        oldpath, newpath = get_paths(root, name)
        if args.interactive:
            interactive(oldpath, newpath)
        elif args.automate:
            rename(oldpath, newpath),
        elif args.dry_run:
            dryrun(oldpath, newpath)
        elif args.quiet:
            os.rename(oldpath, newpath)


def main():
    """
    Reverse walk the filesystem, ending at given path, renaming files
    and then directories as we go.
    """
    args = getargs()
    path = os.path.abspath(args.path)
    if args.create:
        create(path, 0, args.create)
    else:
        for root, dirs, files in os.walk(path, topdown=False):
            for name in files:
                process_args(root, name, args)
            for name in dirs:
                process_args(root, name, args)


if __name__ == '__main__':
    main()
