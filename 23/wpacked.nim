include ../aoc

var elfRotation = 0
const MAGIC = -1
const DIRS = [-256, 256, -1, 1]

proc solve(elfs: var Packeds2D): (int, int) =
    var r = 0
    var props: Table[int, int]

    var blocked: array[65536, int]
    for elf in elfs:
        blocked[elf] = 1
    
    while true:
        inc r
        if r > 1000:
            assert false, "Too too long to run."
            break

        props.clear()

        for elf in elfs:
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
                let x = (i+elfRotation) mod 4
                if rr[x]:
                    let move = elf+DIRS[x]
                    if move notin props:
                        props[move] = elf
                    else:
                        props[move] = MAGIC
                    break

        if props.len == 0:
            break

        for move, elf in props:
            if elf != MAGIC:
                elfs.excl(elf)
                elfs.incl(move)
                blocked[elf] = 0
                blocked[move] = 1

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
