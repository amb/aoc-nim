include aoc
import tracer

let data = "23/input".readFile.strip.split("\n")

var elfCheck: seq[seq[Coord2D]]
for dirs in @[("NE", "N", "NW"), ("SE", "S", "SW"), ("NW", "W", "SW"), ("NE", "E", "SE")]:
    var il: seq[Coord2D]
    il.add(compassRD[dirs[0]])
    il.add(compassRD[dirs[1]])
    il.add(compassRD[dirs[2]])
    elfCheck.add(il)

let surround = compassRD.values.toSeq.toCoords2D
# let elfCheck = surround.values.mapIt(it.coord2d).partitionWrap(offset=-1, size=3, count=4)

const MAGIC = (-555,-555)

proc proposal(elf: Coord2D, tiles: Coords2D): Coord2D {.meter.} =
    for dirs in elfCheck:
        var hasPos = true
        for direction in dirs:
            if (elf+direction) in tiles:
                hasPos = false
                break
        if hasPos:
            return elf+dirs[1]
    return MAGIC

# crd in crds
# crd + crd
# Coord2D -> Packed2D
# Packed2D -> Coord2D

proc getprops(elfs: Coords2D): Table[Coord2D, Coord2D] {.meter.} =
    # Gather suggestions
    for elf in elfs:
        var hugging = false
        for it in surround:
            if elf+it in elfs:
                hugging = true
                break
        if hugging:
            let move = elf.proposal(elfs)
            if move != MAGIC:
                if move notin result:
                    result[move] = elf
                else:
                    result[move] = MAGIC

proc solve(elfs: var Coords2D): (int, int) {.meter.} =
    var r = 0
    while true:
        inc r
        if r > 1000:
            assert false, "Too too long to run."

        let props = getprops(elfs)

        if props.len == 0:
            break

        for move, elf in props:
            if elf != MAGIC:
                elfs.excl(elf)
                elfs.incl(move)

        elfCheck.rollL(0, elfCheck.high)

    let box = elfs.max-elfs.min+(1,1)
    (box[0] * box[1] - elfs.len, r)

metricsConfirm()

var elfs = data.toCoords2D('#')

let width = data[0].len
let height = data.len

echo fmt"w: {width}, h: {height}"
echo fmt"elfs: {elfs.len}"

# let s = oneTimeIt:
let s = solve(elfs)

metricsShow()

assert s == (15173, 963)
echo s

# 15173
# 963
