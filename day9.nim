include aoc

day 9:
    proc touching(a, b: Coord2D): bool =
        let adisp = (a-b).abs
        adisp.x <= 1 and adisp.y <= 1

    proc moveDir(c: char): Option[Coord2D] =
        case c:
            of 'L': some((-1, 0))
            of 'R': some((1, 0))
            of 'U': some((0, -1))
            of 'D': some((0, 1))
            else: none(Coord2D)

    proc follow(tail: var Coord2D, head: Coord2D) =
        let disp = head - tail
        if tail.touching(head): return
        if disp == (-2, 0): tail += (-1, 0)
        elif disp == (2, 0): tail += (1, 0)
        elif disp == (0, -2): tail += (0, -1)
        elif disp == (0, 2): tail += (0, 1)
        else: tail += disp/abs(disp)

    let moves = lines.
        mapIt(it.scanTuple("$c $i")).
        filterIt(it[0]).
        mapIt(it[1].moveDir.get * it[2])

    var knots = newSeq[Coord2D](10)
    var trail1: HashSet[(int, int)]
    var trail9: HashSet[(int, int)]
    for m in moves:
        let dir = m/len(m)
        for step in 0..<m.len:
            knots[0] += dir
            for kn in 1..9:
                knots[kn].follow(knots[kn-1])
            trail1.incl(knots[1].asTuple)
            trail9.incl(knots[9].asTuple)

    part 1, 6067: trail1.len
    part 2, 2471: trail9.len
