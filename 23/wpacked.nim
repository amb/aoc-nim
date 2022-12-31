include ../aoc
import std/[bitops]

const MAGIC = -1
const DIRS = [-256, 256, -1, 1]
const SCAN = [-257, -256, -255, 1, 257, 256, 255, -1]

proc solve(elfs: var Packeds2D): (int, int) =
    var props: Table[int, int]
    var elfRotation = 0
    var blocked: array[65536, int]
    var velfs: seq[Packed2D]
    for elf in elfs:
        blocked[elf] = 1
        velfs.add(elf)

    var r = 0
    while true:
        inc r

        props.clear()
        for ei, elf in velfs:
            let dNW = blocked[elf-257] == 0
            let dN  = blocked[elf-256] == 0
            let dNE = blocked[elf-255] == 0
            let dSW = blocked[elf+255] == 0
            let dS  = blocked[elf+256] == 0
            let dSE = blocked[elf+257] == 0
            let dW  = blocked[elf-1] == 0
            let dE  = blocked[elf+1] == 0

            if dN and dNW and dNE and dS and dSW and dSE and dW and dE:
                continue

            let rr = [dN and dNW and dNE,
                    dS and dSW and dSE,
                    dW and dNW and dSW,
                    dE and dNE and dSE]

            for i in 0..3:
                let x = (i+elfRotation).bitand(3)
                if rr[x]:
                    let move = elf+DIRS[x]
                    if move notin props:
                        props[move] = ei
                    else:
                        props[move] = MAGIC
                    break

        if props.len == 0:
            break

        for move, ei in props:
            if ei != MAGIC:
                blocked[velfs[ei]] = 0
                blocked[move] = 1
                velfs[ei] = move

        elfRotation = (elfRotation+1).bitand(3)

    let relfs = velfs.unpack
    let box = relfs.max - relfs.min + (1,1)
    (box[0] * box[1] - relfs.len, r)

let data = "23/input".readFile.strip.split("\n")
var elfs = data.toCoords2D('#').pack(offset=(31, 31))

let s = oneTimeIt: solve(elfs)

assert s == (15173, 963)
echo s
