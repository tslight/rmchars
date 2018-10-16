import argparse
import os
from yorn import ask

chars = ["\\", "/", "\"", ":", "<", ">", "^", "|", "*", "?", "+"]


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


def replace_chars(name):
    """
    iterate over & delete invalid characters in name.
    """
    for c in chars:
        name = name.replace(c, "")
        name = name.strip()
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
    parser.add_argument("path", type=chkpath, nargs='?',
                        default=".", help="a valid path")
    return parser.parse_args()


def main():
    args = getargs()
    path = os.path.abspath(args.path)
    for root, dirs, files in os.walk(path, topdown=False):
        for name in files:
            rename_path(root, name, args)
        for name in dirs:
            rename_path(root, name, args)


if __name__ == '__main__':
    main()
