include ../aoc

let moves = collect:
    for line in "9/input".readFile.splitLines:
        let (r, d, s) = line.scanTuple("$c $i")
        if r: vec2i(int(d=='R')-int(d=='L'), int(d=='D')-int(d=='U')) * s

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