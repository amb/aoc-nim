include ../aoc

let mdir = {'L': (-1, 0), 'R': (1, 0), 'U': (0, -1), 'D': (0, 1)}.toTable
let moves = collect:
    for line in fil(9):
        let (r, d, s) = line.scanTuple("$c $i")
        if r: vec2i(mdir[d]) * s

proc solve(n: int): HashSet[(int, int)] =
    var knots = newSeq[Vec2i](10)
    for m in moves:
        for step in 0..<m.len:
            knots[0] += sgn(m)
            for kn in 1..9:
                let disp = knots[kn-1] - knots[kn]
                if disp.len > 1:
                    knots[kn] += sgn(disp)
            result.incl(knots[n].asTuple)

echo fmt"1: {solve(1).len}, 2: {solve(9).len}"