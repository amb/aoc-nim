include aoc

day 9:
    let moves = collect:
        for line in lines:
            let (r, d, s) = line.scanTuple("$c $i")
            if r: coord2d(int(d=='R')-int(d=='L'), int(d=='D')-int(d=='U')) * s

    proc solve(n: int): HashSet[(int, int)] =
        var knots = newSeq[Coord2D](10)
        for m in moves:
            for step in 0..<m.len:
                knots[0] += sgn(m)
                for kn in 1..9:
                    let disp = knots[kn-1] - knots[kn]
                    if disp.len > 1:
                        knots[kn] += sgn(disp)
                result.incl(knots[n].asTuple)

    part 1, 6067: solve(1).len
    part 2, 2471: solve(9).len
