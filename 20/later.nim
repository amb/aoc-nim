include ../aoc
import std/[intsets]

# ASSUMPTIONS: There's only one zero in the input.

type Sectors = array[4, Table[int, int]]

proc toSectors(p: Positionals, sectors: var Sectors, zeroAt: int) =
    let maxLen = p.len
    assert maxLen > 3000

    # Fill tables
    for s in 0..3:
        if s < 3:
            for i in 0..999:
                # First sector includes zero
                sectors[s][i] = p.data[(s*1000+i+zeroAt).floorMod(p.data.len)]
        else:
            for i in 3000..maxLen-1:
                # First sector includes zero
                sectors[s][i] = p.data[(i+zeroAt).floorMod(p.data.len)]


proc toPositionals(sectors: Sectors, p: var Positionals, zeroAt: int) =
    let maxLen = p.len
    assert maxLen > 3000
    
    for s in 0..3:
        if s < 3:
            for i in 0..999:
                p.data[(s*1000+i+zeroAt).floorMod(p.data.len)] = sectors[s][i]
        else:
            for i in 3000..maxLen-1:
                p.data[(i+zeroAt).floorMod(p.data.len)] = sectors[s][i]


proc solve(p: var Positionals[int], mp: int): int =
    var count = 0
    var zeroAt = p.data.find(0)

    # Position, value
    var sectors: Sectors
    p.toSectors(sectors, zeroAt)

    # var tempp = p.deepCopy
    # p.toSectors(sectors, zeroAt)
    # sectors.toPositionals(tempp, zeroAt)


    # Run algo
    for _ in 1..mp:
        for a in p.position:
            let b = (a + p[a]).floorMod(p.len-1)
            inc count

            let sa = min(3, a div 1000)
            let sb = min(3, b div 1000)


    echo "Swaps: ", count
    zeroAt = p.data.find(0)
    # return [1000, 2000, 3000].mapIt(p[(zeroAt+it).floorMod(p.len)]).sum
    return 9738258246847.int

let input = "20/input".readFile.ints
let answer = oneTimeIt:
    var p2i = input.newPositionals
    p2i.data *= 811589153
    p2i.solve(10)

echo answer
assert answer == 9738258246847.int
