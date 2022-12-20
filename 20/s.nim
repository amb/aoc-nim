include ../aoc
import std/[enumerate, intsets]

proc solve(p: var Positionals[int], mp: int) =
    for _ in 1..mp:
        for i in 0..p.data.len-1:
            let a = p.position[i]
            let b = (a + p.data[a]).floorMod(p.data.len-1)
            if a < b:
                for j in countup(a, b-1):
                    p.swapItems(j, j+1)
                if b ==  p.data.len - 1:
                    p.rollRight
            elif a > b:
                for j in countdown(a, b+1):
                    p.swapItems(j, j-1)
                if b == 0:
                    p.rollLeft

proc calculate(p: Positionals[int]): int =
    let zeroAt = p.data.find(0)
    [1000, 2000, 3000].mapIt(p.data[(zeroAt+it).floorMod(p.data.len)]).sum

proc parse(ifile: string): Positionals[int] =
    ifile.readFile.strip.splitlines.mapIt(it.parseInt).newPositionals

var p1test = "20/test".parse
solve(p1test, 1)
assert p1test.data == @[1, 2, -3, 4, 0, 3, -2]
assert p1test.position.mapIt(p1test.data[it]) == @[1, 2, -3, 3, -2, 0, 4]
assert calculate(p1test) == 3

var p1i = "20/input".parse
p1i.solve(1)
assert p1i.calculate == 14526

var p2test = "20/test".parse
p2test.data *= 811589153
solve(p2test, 10)
assert p2test.calculate == 1623178306

var p2i = "20/input".parse
p2i.data *= 811589153
solve(p2i, 10)
echo p2i.calculate