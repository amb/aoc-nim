import std/[os, strutils, sequtils, sugar]

let destroy = collect:
    for d in walkDirRec("."):
        if "cleanup" notin d and ".git" notin d and ".exe" in d:
            d

for f in destroy:
    f.removeFile
