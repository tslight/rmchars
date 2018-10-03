import os
from yorn import ask

chars = ["\\", "/", "\"", ":", "<", ">", "^", "|", "*", "?", "+"]


def chkdir(path):
    """
    Checks for valid directory path
    """
    if (not(os.path.isdir(path))):
        err = "INVALID DIRECTORY."
        return err


def replace_chars(path):
    """
    iterate over & delete invalid characters in path.
    """
    for c in chars:
        path = path.replace(c, "")
