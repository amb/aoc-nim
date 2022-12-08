include ../aoc

let data = fil(8)

# let data = """
# 30373
# 25512
# 65332
# 33549
# 35390
# """.splitLines

type
    TreeLocation = tuple[x: int, y: int]
    SetOfTrees = Table[TreeLocation, int]
    TreeItem = tuple[loc: TreeLocation, value: int]
    WarpFunc = proc (ti: TreeItem): TreeItem

# Account for newline at the end
var height: Natural = data.len-1
var width: Natural = data[0].len
echo fmt"Grid size = x: {width}, y: {height}"
doAssert width == height
let asize = width
let szm1 = asize-1

# Gather data
var trees: SetOfTrees
for y, l in data:
    if len(l) > 2:
        for x, c in l:
            doAssert x < asize and y < asize
            trees[(x, y)] = parseInt($c)

proc printTrees(tr: SetOfTrees) =
    var grid = newSeqWith(asize, newSeq[char](asize))
    echo "-".repeat(asize)
    for (k, v) in tr.pairs:
        grid[k[1]][k[0]] = chr(ord('0')+v)
    for i in grid:
        echo i.join
    echo "-".repeat(asize)

proc scanTrees(tr: SetOfTrees): SetOfTrees =
    # Scan from top to bottom
    var scanline: seq[TreeItem] = collect:
        for i in 0..<asize: (loc: (i, 0), value: tr[(i, 0)])
    var foundTrees = scanline.deepCopy
    for x in 0..<asize:
        for y in 0..<asize:
            if tr[(x, y)] > scanline[x].value:
                let newEntry = (loc: (x: x, y: y), value: tr[(x, y)])
                scanline[x] = newEntry
                foundTrees.add(newEntry)
    return foundTrees.toTable

proc tableWarp(tr: SetOfTrees, warp: WarpFunc): SetOfTrees =
    result = collect:
        for k, v in tr.pairs:
            let r = warp((k, v))
            {r[0]: r[1]}

proc flipH(l: TreeLocation): TreeLocation = (l.x, szm1-l.y)
proc tsp(l: TreeLocation): TreeLocation = (l.y, l.x)

proc tfB(tr: SetOfTrees): SetOfTrees = tr.tableWarp(t => (t.loc.flipH, t.value))
proc tfL(tr: SetOfTrees): SetOfTrees = tr.tableWarp(t => (t.loc.tsp, t.value))
proc tfR(tr: SetOfTrees): SetOfTrees = tr.tableWarp(t => (t.loc.tsp.flipH, t.value))

# Order matters
doAssert trees.tfR.tfB.tfL == trees

var scanned = newSeq[SetOfTrees]()
scanned.add(scanTrees(trees))
scanned.add(scanTrees(trees.tfB).tfB)
scanned.add(scanTrees(trees.tfL).tfL)
scanned.add(scanTrees(trees.tfR).tfB.tfL)

echo scanned.mapIt(it.keys.toSeq).concat.deduplicate.len

# echo {(1,0): 'y', (0,5): 'x'}.type.name
# echo {(1, 0): Natural(5)}.type.name
