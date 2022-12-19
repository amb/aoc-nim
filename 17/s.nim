include ../aoc
import std/[bitops]

type Grid[T] = seq[seq[T]]

type
    Piece = object
        grid: Grid[int]
        width, height: int

type
    RingGrid = object
        grid: Grid[int]
        size: int
        maxSize: int

proc newRingGrid(msize: int): RingGrid =
    assert msize > 0
    result.maxSize = msize
    result

proc get(cl: RingGrid, i, j: int): int =
    cl.grid[i mod cl.maxSize][j]

proc set(cl: var RingGrid, i, j: int, val: int) =
    cl.grid[i mod cl.maxSize][j] = val

proc len(cl: RingGrid): int = cl.size

proc add(cl: var RingGrid) =
    assert cl.maxSize != 0
    if cl.grid.len < cl.maxSize:
        cl.grid.add(newSeq[int](7))
        cl.size = cl.grid.len
    else:
        inc cl.size
        let yloc = (cl.size-1) mod cl.maxSize
        for i in 0..6:
            cl.grid[yloc][i] = 0


type
    Engine = object
        ringGrid: RingGrid
        highPoint: int
        blocksCount: int
        windCounter: int
        codes: seq[uint8]
        loopcount: seq[int]

proc newEngine(): Engine =
    Engine(ringGrid: newRingGrid(4000))

proc show(e: Engine) =
    for l in e.ringGrid.grid:
        echo "|" & l.mapIt(if it==1: "#" else: " ").join & "|"

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
let winds = "17/input".readFile.mapIt(if it=='<': -1 else: 1)

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
#
# These grids are indexed from opposite ends vertically

proc collideLine(blk: Piece, blkx, blky: int, clt: RingGrid, y: int): int =
    let cltIdx = -1-y
    let blkIdx = -(blky-y)
    for i in 0..<blk.width:
        let cvl = clt.get(cltIdx, blkx+i)
        let gvl = blk.grid[blkIdx][i]
        result = bitor(result, cvl * gvl)

proc collide(blk: Piece, blkx, blky: int, clt: RingGrid): int =
    if blky+blk.height-1 >= 0:
        return 1
    for blkl in 0..<blk.height:
        let yl = blky + blkl
        if -1-yl < clt.len:
            result = bitor(result, collideLine(blk, blkx, blky, clt, yl))

proc run(e: var Engine, cycles: int): int =
    var x, y: int
    while e.blocksCount < cycles:
        var blk = blocks[e.blocksCount mod blocks.len]
        inc e.blocksCount

        x = 2
        y = e.highPoint - 3 - blk.height

        # Make the piece fall down
        while true:
            # Wind test
            let wind = winds[e.windCounter mod winds.len]
            inc e.windCounter
            if x+wind >= 0 and x+wind+blk.width-1 <= 6:
                if collide(blk, x+wind, y, e.ringGrid) == 0:
                    x=x+wind
            # Ground collision
            if collide(blk, x, y+1, e.ringGrid) != 0:
                break
            inc y

        # If not enough space to draw piece, add more
        let newRows = -y-e.ringGrid.len
        for i in 0..<newRows:
            e.ringGrid.add()

        # Draw piece
        for i in 0..<blk.height:
            let yl = i+y
            for xl in x..<x+4:
                if blk.grid[i][xl-x] == 1:
                    e.ringGrid.set(-yl-1, xl, 1)

        if e.codes.len < 500000:
            for i in e.ringGrid.len-newRows..<e.ringGrid.len:
                var code = 0
                for j in 0..6:
                    code = bitor(code, e.ringGrid.get(i, j) shl j)
                e.codes.add(code.uint8)
                e.loopcount.add(e.blocksCount.int)

            assert e.ringGrid.size == e.codes.len

        e.highPoint = min(y, e.highPoint)
        # assert highPoint == -RingGrid.len, fmt"Hp: {highPoint}, Cl: {-RingGrid.len}"
    e.ringGrid.len

proc getRepeatingResult(e: var Engine, tryCount, totalCount: int): int =
    let p2 = e.run(tryCount)
    let res = e.codes.searchSeq(e.codes[^100..^1].mapIt(it.uint8)).toSeq

    var a = res[0]
    var b = res[1]
    while e.codes[a] == e.codes[b]:
        dec a; dec b
    inc a; inc b

    # echo fmt"Repeating part: {a} -> {b}"
    # echo fmt"At iterations: {e.loopcount[a]}, {e.loopcount[b]}"
    # echo fmt"So, {e.loopcount[b]-e.loopcount[a]} iterations gives {b-a} increase after {a}."

    # Repeating segment playback
    let loopDiff = e.loopcount[b]-e.loopcount[a]
    let repetitions = (totalCount-e.loopcount[a]) div loopDiff
    var headLoc = e.loopcount[a] + loopDiff * repetitions
    var rowCount = a + (b-a) * repetitions

    # NOTE: I got stuck here for so long because of faulty assumptions:
    #       Sometimes headLoc increases, but rowCount does not---is the right way
    for rowLoc in a+(b-a)..<b+(b-a):
        let thisLoop = e.loopcount[rowLoc]
        let previousLoop = e.loopcount[rowLoc-1]
        if thisLoop > previousLoop:
            if headLoc > totalCount:
                break
            headLoc += thisLoop - previousLoop
        inc rowCount

    rowCount

# Part 1
var engine = newEngine()
let p1 = engine.run(2022)
assert p1 == 3175

# Part 2
engine = newEngine()
let p2 = engine.getRepeatingResult(10_000, 1000000000000.int)
assert p2 == 1555113636385

for i in 1..10:
    let tval = 5000 + i*3333

    engine = newEngine()
    let ta = engine.getRepeatingResult(10_000, tval)

    engine = newEngine()
    let tb = engine.run(tval)

    assert ta == tb, fmt"Not matching for {i} ({tval}): {ta}, {tb}"
