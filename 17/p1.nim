include ../aoc

type Grid[T] = seq[seq[T]]

type
    Piece = object
        grid: Grid[int]
        width, height: int

const CLMAX = 4000

type
    Clutter = object
        grid: Grid[int]
        head, size: int

proc get(cl: Clutter, i, j: int): int =
    assert i > cl.size - CLMAX
    cl.grid[(i+cl.head) mod CLMAX][j]

proc set(cl: var Clutter, i, j: int, val: int) =
    assert i > cl.size - CLMAX
    cl.grid[(i+cl.head) mod CLMAX][j] = val

proc len(cl: Clutter): int = cl.size

proc add(cl: var Clutter) =
    if cl.grid.len < CLMAX:
        cl.grid.add(newSeq[int](7))
        cl.size = cl.grid.len
    else:
        cl.head = (cl.head + 1) mod CLMAX
        inc cl.size
        for i in 0..6:
            cl.set(cl.size-1, i, 0)

# Read blocks
let bdata = "17/blocks".readFile.split("\n\n")
var blocks: seq[Piece]
for blk in bdata:
    var newBlock: Grid[int]
    var width: int
    for line in blk.split('\n'):
        var scanline = newSeq[int](4)
        for ci, c in line:
            let occupied = (if c=='#': 1 else: 0)
            if occupied == 1:
                width = max(ci, width)
            scanline[ci] = occupied
        newBlock.add(scanline)
    blocks.add(Piece(grid: newBlock, width: width+1, height: newBlock.len))

# Read test data
let winds = "17/input".readFile
for i in winds:
    assert i != '\n'

# chamber width: 7
# rocks appear at loc 2, starting from 0
# appear: space between rock bottom and highest point is 3

# blk.height = 2
# highPoint = 0
# => y = 0-3 - 2 = -5
#
# |.@@....| <- y: -5
# |.@@....|
# |.......|
# |.......|
# |.......|
# +-------+ <- y: 0
#  ^ x: 0
#
# y up, x right

# These grids are indexed from opposite ends vertically
proc collideLine(blk: Piece, blkx, blky: int, clt: Clutter, y: int): bool =
    let cltIdx = -1-y

    if cltIdx < 0:
        return false

    if clt.len==0:
        return false

    if cltIdx >= clt.len:
        return false

    if y<blky or y>blky+(blk.height-1):
        assert false, "Not inside block"

    let blkIdx = -(blky-y)
    if blkIdx < 0 or blkIdx >= blk.height:
        assert false, "wrong block index"

    for i in 0..<blk.width:
        # if clt[cltIdx][blkx+i] != 0 and
        if clt.get(cltIdx, blkx+i) != 0 and
            blk.grid[blkIdx][i] != 0:
            return true

proc collide(blk: Piece, blkx, blky: int, clt: Clutter): bool =
    if blky+blk.height-1 >= 0:
        return true

    for blkl in 0..<blk.height:
        if collideLine(blk, blkx, blky, clt, blky + blkl):
            return true
    return false

# clutter 0-index is lowest point
# var clutter: Grid[int]
var clutter: Clutter
var highPoint = 0
var x, y: int

var blocksCount = 0
var windCounter = 0

let windDir = {'<': -1, '>': 1}.toTable

# while blocksCount < 5:
while blocksCount < 2022:
    var blk = blocks[blocksCount mod blocks.len]
    inc blocksCount

    x = 2
    y = highPoint - 3 - blk.height - 1

    # Make the piece fall down
    while true:
        inc y

        # Wind test
        let wind = windDir[winds[windCounter mod winds.len]]
        inc windCounter
        if x+wind >= 0 and x+wind+blk.width-1 <= 6:
            if not collide(blk, x+wind, y, clutter):
                x=x+wind

        # Ground collision
        if collide(blk, x, y+1, clutter):
            break

    assert y < 0

    # If not enough space to draw piece, add more
    for i in 0..<(-y-clutter.len):
        clutter.add()

    # Draw piece
    for i in 0..<blk.height:
        let yl = i+y
        for xl in x..<x+4:
            if blk.grid[i][xl-x] == 1:
                clutter.set(-yl-1, xl, 1)

    highPoint = min(y, highPoint)
    assert highPoint == -clutter.len, fmt"Hp: {highPoint}, Cl: {-clutter.len}"

# for l in clutter:
#     echo "|" & l.mapIt(if it==1: "#" else: " ").join & "|"

# Part 1
echo clutter.len
# assert clutter.len == 3175