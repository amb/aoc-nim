include ../aoc

let data = "24/input".readFile.strip.split("\n")
var blizzards: seq[seq[seq[int]]]
for c in ['>', '<', '^', 'v']:
    blizzards.add(data.toCoords2D(c).toGrid((data[0].len-2, data.len-2), offset=(1, 1)))
let (width, height) = (blizzards[0][0].len, blizzards[0].len)

proc blizVal(nv: (int, int), step: int): int =
    let (x, y) = nv
    blizzards[0][y][(x-step).floorMod(width)] +
    blizzards[1][y][(x+step).floorMod(width)] +
    blizzards[2][(y+step).floorMod(height)][x] +
    blizzards[3][(y-step).floorMod(height)][x]

proc walk(a, b: Coord2D, start: int): int =
    var step = start
    var heads: Coords2D
    while b notin heads:
        for n in heads.neighbours:
            if n.inBounds(width, height) and blizVal(n, step) == 0:
                heads.incl(n)
        heads.incl(a)
        for h in heads.toSeq:
            if blizVal(h, step) > 0:
                heads.excl(h)
        inc step
    step

let wh1 = (width-1, height-1)
let a = oneTimeIt: walk((0, 0), wh1, walk(wh1, (0, 0), walk((0, 0), wh1, 0)))
echo a