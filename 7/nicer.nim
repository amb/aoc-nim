include ../aoc
import npeg, std/tables, std/hashes

type 
    FileItem = ref object
        # -1 root, 0 dir, 1+ file
        size: int
        name: string
        containedSize: int
        parent: FileItem
        items: Table[string, FileItem]

proc repr(x: FileItem): string = 
    if x.size <= 0:
        result = fmt"{x.name} (dir)"
    else:
        result = fmt"{x.name} (file, size={x.size})"
    result &= fmt" <{x.containedSize}>"

var dirData = FileItem(size: -1, name: "root")
var rootFolder = dirData
var cwd = dirData

proc isRoot(i: FileItem): bool = i.name == "root" and i.size == -1

proc allParents(i: FileItem): seq[FileItem] =
    # Include self
    var citem = i
    while not isRoot(citem):
        result.add(citem)
        citem = citem.parent
    # Add root too
    result.add(citem)

proc newItem(size: int, name: string): FileItem =
    doAssert not (name in cwd.items)
    result = FileItem(size: size, containedSize: 0, name: name, parent: cwd)
    if size > 0:
        for p in result.allParents:
            p.containedSize += size
    cwd.items[name] = result

let parser = peg "input":
    input <- +(?line * '\n')
    line <- command
    command <- "$ " * +(cd | ls)
    cd <- "cd " * >(".." | "/" | (+Alpha)): 
        if $1 == "/":
            cwd = rootFolder
        elif $1 == "..":
            doAssert not isRoot(cwd)
            cwd = cwd.parent
        else:
            doAssert not ($1 in cwd.items)
            cwd = newItem(0, $1)
            # echo "Dir: ", $1, " to ", allParents(cwd).mapIt(it.name).join("/")
    ls <- "ls" * listing
    listing <- +('\n' * (lsfile|lsdir))
    lsfile <- >(+Digit) * ' ' * >(+{'a'..'z','.'}):
        discard newItem(parseInt($1), $2)
        # echo "File: ", $2, " ", $1
    lsdir <- "dir " * (+Alpha)

var test_input = """
$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k
"""

echo parser.match(test_input).ok
# echo parser.match("7/input".readFile).ok

proc printTree(fi: FileItem, d: int) =
    echo "  ".repeat(d) & "- " & fi.repr
    for k in fi.items.keys.toSeq.sorted:
        printTree(fi.items[k], d+1)

printTree(rootFolder, 0)