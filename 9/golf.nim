include ../aoc
proc follow(tail: var Coord2D, head: Coord2D) =
    let ds = head - tail
    if ds.len > 1: tail += (if ds.x * ds.y == 0: ds/len(ds) else: ds/abs(ds))
let mdir = {'L': coord2d(-1, 0), 'R': coord2d(1, 0), 'U': coord2d(0, -1), 'D': coord2d(0, 1)}.toTable
var knots = newSeq[Coord2D](10)
var trail1, trail9: HashSet[(int, int)]
for m in fil(9).mapIt(it.scanTuple("$c $i")).filterIt(it[0]).mapIt(mdir[it[1]] * it[2]):
    for step in 0..<m.len:
        knots[0] += m/len(m)
        for kn in 1..9: knots[kn].follow(knots[kn-1])
        trail1.incl(knots[1].asTuple)
        trail9.incl(knots[9].asTuple)
echo fmt"1: {trail1.len}, 2: {trail9.len}"