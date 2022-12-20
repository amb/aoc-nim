include ../aoc

proc solve(p: var Positionals[int], mp: int): int =
    for _ in 1..mp:
        for a in p.position:
            let b = (a + p[a]).floorMod(p.len-1)
            if a < b:
                for j in countup(a, b-1):
                    p.swapItems(j, j+1)
                if b ==  p.len - 1:
                    p.rollRight()
            elif a > b:
                for j in countdown(a, b+1):
                    p.swapItems(j, j-1)
                if b == 0:
                    p.rollLeft()

    let zeroAt = p.data.find(0)
    return [1000, 2000, 3000].mapIt(p[(zeroAt+it).floorMod(p.len)]).sum

let input = "20/input".readFile.ints
var p1i = input.newPositionals
assert p1i.solve(1) == 14526

var p2i = input.newPositionals
p2i.data *= 811589153
assert p2i.solve(10) == 9738258246847
