import argparse
import os
import re
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


def replace_chars(path):
    """
    iterate over & delete invalid characters in path.
    """
    for c in chars:
        path = path.replace(c, "")
    return path


def rename_path(root, path):
    new_name = replace_chars(path)
    os.rename(os.path.join(root, path), os.path.join(root, new_name))


def traverse(path):
    for root, dirs, files in os.walk(path, topdown=False):
        for name in dirs:
            found = re.search(r'[%s]' % ''.join(chars), name)
            if found:
                print("Invalid characters found in {0}".format(name))
                question = "Would you like to rename " + \
                    name + " to " + replace_chars(name) + " ? "
                if ask(question):
                    rename_path(root, name)
        for name in files:
            found = re.search(r'[%s]' % ''.join(chars), name)
            if found:
                print("Invalid characters found in {0}".format(name))
                question = "Would you like to rename " + \
                    name + " to " + replace_chars(name) + " ? "
                if ask(question):
                    rename_path(root, name)


def getargs():
    """
    Return a list of valid arguments. If no argument is given, default to $PWD.
    """
    parser = argparse.ArgumentParser(
        description='Remove invalid characters from a given path.')
    parser.add_argument("path", type=chkpath, nargs='?',
                        default=".", help="A valid path.")
    return parser.parse_args()


def main():
    args = getargs()
    path = os.path.abspath(args.path)
    traverse(path)


if __name__ == '__main__':
    main()
