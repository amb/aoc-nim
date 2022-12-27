include ../aoc

var elfRotation = 0
const MAGIC = (600, 601).packed2d
const DIRS = [-256, 256, -1, 1]

proc getpropsB(elfs: Packeds2D, tb: var Table[int, int]) =
    for elf in elfs:
        let dNW = (elf-257) notin elfs
        let dN  = (elf-256) notin elfs
        let dNE = (elf-255) notin elfs
        let dSW = (elf+255) notin elfs
        let dS  = (elf+256) notin elfs
        let dSE = (elf+257) notin elfs
        let dW  = (elf-1) notin elfs
        let dE  = (elf+1) notin elfs

        if dN and dNW and dNE and dS and dSW and dSE and dW and dE:
            continue
        
        let rr = [dN and dNW and dNE, 
                  dS and dSW and dSE, 
                  dW and dNW and dSW, 
                  dE and dNE and dSE]

        for i in 0..3:
            let x = (i+elfRotation) mod 4
            if rr[x]:
                let move = elf+DIRS[x]
                if move notin tb:
                    tb[move] = elf
                else:
                    tb[move] = MAGIC
                break


proc solve(elfs: var Packeds2D): (int, int) =
    var r = 0
    var props: Table[int, int]
    while true:
        inc r
        if r > 1000:
            assert false, "Too too long to run."
            break

        props.clear()
        getpropsB(elfs, props)
        if props.len == 0:
            break

        for move, elf in props:
            if elf != MAGIC:
                elfs.excl(elf)
                elfs.incl(move)

        inc elfRotation
        if elfRotation == 4:
            elfRotation = 0

    let relfs = elfs.unpack
    let box = relfs.max-relfs.min+(1,1)
    (box[0] * box[1] - relfs.len, r)

let data = "23/input".readFile.strip.split("\n")
var elfs = data.toCoords2D('#').pack(offset=(31, 31))

let width = data[0].len
let height = data.len

echo fmt"w: {width}, h: {height}"
echo fmt"elfs: {elfs.len}"

let s = oneTimeIt: solve(elfs)

assert s == (15173, 963)
echo s

# 15173
# 963
