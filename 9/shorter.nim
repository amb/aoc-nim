include ../aoc

let mdir = {'L': (-1, 0), 'R': (1, 0), 'U': (0, -1), 'D': (0, 1)}.toTable
let moves = collect:
    for line in fil(9):
        let (r, d, s) = line.scanTuple("$c $i")
        if r: vec2i(mdir[d]) * s

var knots = newSeq[Vec2i](10)
var trail1, trail9: HashSet[(int, int)]
for m in moves:
    let dir = sgn(m)
    for step in 0..<m.len:
        knots[0] += dir
        for kn in 1..9:
            let disp = knots[kn-1] - knots[kn]
            if disp.len > 1:
                knots[kn] += sgn(disp)
        trail1.incl(knots[1].asTuple)
        trail9.incl(knots[9].asTuple)

echo fmt"1: {trail1.len}, 2: {trail9.len}"