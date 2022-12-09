include ../aoc

proc follow(tail: var Vec2i, head: Vec2i) =
    let disp = head - tail
    if disp.len > 1:
        tail += (if disp.x * disp.y == 0: disp/len(disp) else: disp/abs(disp))

let mdir = {'L': vec2i(-1, 0), 'R': vec2i(1, 0), 'U': vec2i(0, -1), 'D': vec2i(0, 1)}.toTable
let moves = collect:
    for line in fil(9):
        let (r, d, s) = line.scanTuple("$c $i")
        if r: mdir[d] * s

var knots = newSeq[Vec2i](10)
var trail1, trail9: HashSet[(int, int)]
for m in moves:
    let dir = m/len(m)
    for step in 0..<m.len:
        knots[0] += dir
        for kn in 1..9:
            knots[kn].follow(knots[kn-1])
        trail1.incl(knots[1].asTuple)
        trail9.incl(knots[9].asTuple)

echo fmt"1: {trail1.len}, 2: {trail9.len}"