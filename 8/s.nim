include ../aoc
import typetraits

# let data = fil(8)

let data = """
30373
25512
65332
33549
35390
""".splitLines
echo data

type 
    TreeLocation = tuple[x: int, y: int]
    TreeItem = array[0..0, (TreeLocation, Natural)]
    SetOfTrees = Table[TreeLocation, Natural]
    WarpFunc = proc (k: TreeLocation, v: Natural): TreeItem

var trees: SetOfTrees
# echo trees.pairs.toSeq[0]

# Account for newline at the end
var height: Natural = data.len-1
var width: Natural = data[0].len
echo fmt"Grid size = x: {width}, y: {height}"
doAssert width == height
let asize = width

# Gather data
for y, l in data:
    if len(l) > 2:
        for x, c in l:
            doAssert x < asize and y < asize
            trees[(x, y)] = parseInt($c)

proc scanTrees(tr: SetOfTrees): seq[tuple[loc: int, value: int]] =
    # Scan from top to bottom
    var visible = collect: 
        for i in 0..<asize: (loc: 0, value: -1)
    for x in 0..<asize:
        for y in 0..<asize:
            if tr[(x, y)] > visible[x].value:
                visible[x] = (loc: y, value: tr[(x, y)])
    return visible

echo scanTrees(trees)

proc keyWarpWorks(tr: SetOfTrees): SetOfTrees =
    result = collect:
        for k, v in trees.pairs:
            {(-k[1], k[0]): v}

proc keyWarpBroken(tr: SetOfTrees, warp: proc (k: TreeLocation, v: Natural): TreeItem): SetOfTrees =
    result = collect:
        for k, v in trees.pairs:
            warp(k, v)

# echo scanTrees(trees.keyWarp(k, v => {(-k[1], k[0]): v}))

# echo {(1,0): 'y', (0,5): 'x'}.type.name
# echo {(1, 0): Natural(5)}.type.name
