include ../aoc

proc follow(tail: var Vec2i, head: Vec2i) =
    let disp = head - tail
    if abs(disp.x) > 1 or abs(disp.y) > 1:
        tail += (if disp.x * disp.y == 0: disp/len(disp) else: disp/abs(disp))

let mdir = {'L': vec(-1, 0), 'R': vec(1, 0), 'U': vec(0, -1), 'D': vec(0, 1)}.toTable
var knots = newSeq[Vec2i](10)
var trail1, trail9: HashSet[(int, int)]
for m in fil(9).mapIt(it.scanTuple("$c $i")).filterIt(it[0]).mapIt(mdir[it[1]] * it[2]):
    let dir = m/len(m)
    for step in 0..<m.len:
        knots[0] += dir
        for kn in 1..9:
            knots[kn].follow(knots[kn-1])
        trail1.incl(knots[1].asTuple)
        trail9.incl(knots[9].asTuple)

echo fmt"1: {trail1.len}, 2: {trail9.len}"