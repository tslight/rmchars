import argparse
import os

if os.name == 'nt':
    chars = ['/', '"', ':', '<', '>', '^', '|', '*', '?', '+']
else:
    chars = ['\\', '"', ':', '<', '>', '^', '|', '*', '?', '+']


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
    parser = argparse.ArgumentParser(
        description='Create a bunch of insane files and directories.')
    parser.add_argument("path", type=chkpath, nargs='?',
                        default=".", help="A valid path.")
    return parser.parse_args()


def mknames(name):
    names = []
    for i in range(10):
        newname = name + str(i)
        for c in chars:
            newname = " " + c + " " + newname + " " + c + " "
        newname = "   " + newname + "   "
        names.append(newname)

    return names


def mknodes(path):
    dirs = mknames("testdir")
    files = mknames("testfile")
    for d in dirs:
        if not os.path.exists(d):
            os.mkdir(os.path.join(path, d))
    for f in files:
        if not os.path.exists(f):
            open(os.path.join(path, f), 'a').close()


def main():
    args = getargs()
    path = os.path.abspath(args.path)
    mknodes(path)


if __name__ == '__main__':
    main()
