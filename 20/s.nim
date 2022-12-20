include ../aoc
import std/[enumerate, intsets]

proc roller(p: var Positionals, aloc, bloc: var int) =
    ## If moved to the edge, roll around
    if bloc == p.data.len-1:
        p.rollRight()
        aloc = bloc
        bloc = 0
    elif bloc == 0:
        p.rollLeft()
        aloc = bloc
        bloc = p.data.len-1

proc solve(ifile: string): Positionals[int] =
    var input = collect:
        for line in ifile.readFile.strip.splitLines:
            line.parseInt

    var p = newPositionals(input)

    for i in 0..p.data.len-1:
        let loc = p.position[i]
        let dir = p.data[loc].sgn
        if dir == 0:
            continue
        
        var aloc = loc
        var bloc = loc+dir
        
        if bloc < 0:
            p.rollLeft()
            bloc = p.data.len-2
            aloc = p.data.len-1
        elif bloc >= p.data.len:
            p.rollRight()
            bloc = 1
            aloc = 0

        for _ in 1..abs(p.data[loc]):
            p.swapItems(aloc, bloc)
            p.roller(aloc, bloc)
            bloc = (bloc+dir).floorMod(p.data.len)
            aloc = (aloc+dir).floorMod(p.data.len)

    return p

proc calculate(p: Positionals[int]): int =
    let zeroAt = p.data.find(0)
    [1000, 2000, 3000].mapIt(p.data[(zeroAt+it).floorMod(p.data.len)]).sum


let p1test = solve("20/test")
assert p1test.data == @[1, 2, -3, 4, 0, 3, -2]
assert p1test.position.mapIt(p1test.data[it]) == @[1, 2, -3, 3, -2, 0, 4]
assert calculate(p1test) == 3

echo solve("20/input").calculate


# Not -3052
# Not 9735, too low
