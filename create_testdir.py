# -*- coding: utf-8 -*-
import os
# import sys
# sys.setdefaultencoding('utf-8')
# reload(sys)

chars = ['\\', '/', '"', ':', '<', '>', '^', '|', '*', '?', '+']


def makenames(name):
    names = []
    for i in range(10):
        newname = name + str(i)
        for c in chars:
            newname = newname + c
        names.append(newname)

    return names


def main():
    dirs = makenames("testdir")
    files = makenames("testfile")
    for d in dirs:
        # d = d.decode('unicode_escape').encode("utf8")
        if not os.path.exists(d):
            os.mkdir(d)
    for f in files:
        # f = f.decode('unicode_escape')
        if not os.path.exists(f):
            open(f, 'a').close()


if __name__ == '__main__':
    main()
