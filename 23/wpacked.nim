include ../aoc
import ../tracer

let data = "23/input".readFile.strip.split("\n")

var elfCheck: seq[seq[Packed2D]]
for dirs in @[("NE", "N", "NW"), ("SE", "S", "SW"), ("NW", "W", "SW"), ("NE", "E", "SE")]:
    var il: seq[Packed2D]
    il.add(compassRD[dirs[0]].packed2d)
    il.add(compassRD[dirs[1]].packed2d)
    il.add(compassRD[dirs[2]].packed2d)
    elfCheck.add(il)

let surround = compassRD.values.toSeq.pack

const MAGIC = (60000,60001).packed2d

proc proposal(elf: Packed2D, tiles: Packeds2D): Packed2D {.meter.} =
    for dirs in elfCheck:
        var hasPos = true
        for direction in dirs:
            if (elf+direction) in tiles:
                hasPos = false
                break
        if hasPos:
            return elf+dirs[1]
    return MAGIC

proc getprops(elfs: Packeds2D, tb: var Table[Packed2D, Packed2D]) {.meter.} =
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
                if move notin tb:
                    tb[move] = elf
                else:
                    tb[move] = MAGIC

proc solve(elfs: var Packeds2D): (int, int) {.meter.} =
    var r = 0
    var props: Table[Packed2D, Packed2D]
    while true:
        inc r
        if r > 1000:
            assert false, "Too too long to run."

        props.clear()
        getprops(elfs, props)

        if props.len == 0:
            break

        for move, elf in props:
            if elf != MAGIC:
                elfs.excl(elf)
                elfs.incl(move)

        elfCheck.rollL(0, elfCheck.high)

    let relfs = elfs.unpack
    let box = relfs.max-relfs.min+(1,1)
    (box[0] * box[1] - relfs.len, r)

metricsConfirm()

var elfs = data.toCoords2D('#').pack(offset=(31, 31))

echo elfs.max
echo elfs.min

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
