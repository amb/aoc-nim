import std/[os, strutils, sequtils, sugar]

let destroy = collect:
    for d in walkDirRec("."):
        if "cleanup" notin d and ".git" notin d:
            d

for f in destroy:
    if fpUserExec in f.getFileInfo.permissions:
        echo "Removing: ", f
        f.removeFile
