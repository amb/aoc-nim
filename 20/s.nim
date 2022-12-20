include ../aoc

proc solve(p: var Positionals[int], mp: int) =
    for _ in 1..mp:
        for i in 0..p.data.len-1:
            let a = p.position[i]
            let b = (a + p.data[a]).floorMod(p.data.len-1)
            if a < b:
                for j in countup(a, b-1):
                    p.swapItems(j, j+1)
                if b ==  p.data.len - 1:
                    p.rollRight()
            elif a > b:
                for j in countdown(a, b+1):
                    p.swapItems(j, j-1)
                if b == 0:
                    p.rollLeft()

proc calculate(p: Positionals[int]): int =
    let zeroAt = p.data.find(0)
    [1000, 2000, 3000].mapIt(p.data[(zeroAt+it).floorMod(p.data.len)]).sum

proc parse(ifile: string): seq[int] =
    ifile.readFile.strip.splitlines.mapIt(it.parseInt)

let p1d = "20/input".parse
var p1i = p1d.newPositionals
p1i.solve(1)
assert p1i.calculate == 14526

var p2i = p1d.newPositionals
p2i.data *= 811589153
solve(p2i, 10)
assert p2i.calculate == 9738258246847