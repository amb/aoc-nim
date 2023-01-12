include aoc

day 20:
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

    let iints = input.ints

    var p1i = iints.newPositionals
    var p2i = iints.newPositionals
    p2i.data *= 811589153

    part 1, 14526: p1i.solve(1)
    part 2, 9738258246847.int64: p2i.solve(10)
