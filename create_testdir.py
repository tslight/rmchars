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
    for i in range(len(chars)):
        newname = name + str(i)
        newname = chars[i] + " " + newname + " " + chars[i]
        newname = "  " + newname + "  "
        names.append(newname)

    return names


def mknodes(path):
    dirs = mknames("testdir")
    files = mknames("testfile")
    for d in dirs:
        dirpath = os.path.join(path, d)
        if not os.path.exists(dirpath):
            os.mkdir(dirpath)
    for f in files:
        filepath = os.path.join(path, f)
        if not os.path.exists(filepath):
            open(filepath, 'a').close()


def recurse(path):
    for d in os.listdir(path):
        dirpath = os.path.join(path, d)
        if os.path.isdir(dirpath):
            mknodes(dirpath)


def main():
    args = getargs()
    path = os.path.abspath(args.path)
    mknodes(path)
    recurse(path)


if __name__ == '__main__':
    main()
