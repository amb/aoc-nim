include ../aoc
import npeg, std/tables, std/hashes

type 
    FileItem = ref object
        # -1 root, 0 dir, 1+ file
        size: int
        name: string
        parent: FileItem
        items: Table[string, FileItem]

var dirData = FileItem(size: -1, name: "root")
var rootFolder = dirData
var cwd = dirData

proc newItem(size: int, name: string): FileItem =
    result = FileItem(size: size, name: name, parent: cwd)
    cwd.items[name] = result

let parser = peg "input":
    input <- +(?command * '\n')
    command <- "$ " * +(cd | ls)
    cd <- "cd " * >(".." | "/" | (+Alpha)): 
        cwd = (if $1 == "/": rootFolder elif $1 == "..": cwd.parent else: newItem(0, $1))
    ls <- "ls" * +('\n' * (lsfile|lsdir))
    lsfile <- >(+Digit) * ' ' * >(+{'a'..'z','.'}):
        discard newItem(parseInt($1), $2)
    lsdir <- "dir " * (+Alpha)

echo parser.match(filr(7)).ok

proc sizeWalk(fi: FileItem, sizes: var seq[(FileItem, int)]): int =
    result = fi.size
    for k in fi.items.keys:
        result += sizeWalk(fi.items[k], sizes)
    if fi.size <= 0:
        sizes.add((fi, result))

var sz = newSeq[(FileItem, int)]()
discard sizeWalk(rootFolder, sz)

let moreSpace = 30_000_000 - (70_000_000 - sz[^1][1])
echo sz.filterIt(it[1] >= moreSpace).sorted((x, y) => x[1] > y[1])[0][1]
