include ../aoc

proc solve(p: var Positionals[int], mp: int): int =
    for _ in 1..mp:
        for a in p.position:
            let b = (a + p[a]).floorMod(p.len-1)
            if a < b:
                p.rollLeft(a, b)
            elif a > b:
                p.rollRight(b, a)
    let zeroAt = p.data.find(0)
    return [1000, 2000, 3000].mapIt(p[(zeroAt+it).floorMod(p.len)]).sum

let input = "20/input".readFile.ints
let answer = oneTimeIt:
    var p1i = input.newPositionals
    var p2i = input.newPositionals
    p2i.data *= 811589153
    (p1i.solve(1), p2i.solve(10))

echo answer
assert answer == (14526, 9738258246847.int)
