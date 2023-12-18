import ../aoc
import ../coords
import std/[sequtils, strutils, strformat, enumerate, tables, sets, math, options, algorithm]

day 11:
    let lines = input.splitLines

    # find empty rows
    var emptyRows: seq[int]
    for li, l in lines:
        if l.count('#') == 0:
            emptyRows.add(li)

    # find empty columns
    var emptyCols: seq[int]
    for ci in 0..lines[0].high:
        var counter = 0
        for li in 0..lines.high:
            if lines[li][ci] == '#':
                inc counter
        if counter == 0:
            emptyCols.add(ci)

    # all stars
    var starMap = lines.toCoords2D('#').toSeq

    proc expand(starMap: seq[Coord2D], expansionStep: int): seq[Coord2D] =
        result = starMap

        # expand rows
        for ri, r in emptyRows:
            for gi, g in result:
                if g.y > r + ri * expansionStep:
                    result[gi] = g + (0, expansionStep)

        # expand cols
        for ci, c in emptyCols:
            for gi, g in result:
                if g.x > c + ci * expansionStep:
                    result[gi] = g + (expansionStep, 0)

    # calc comb sums
    proc combSums(starMap: seq[Coord2D]): int =
        for i in 0..<starMap.len:
            for j in 0..i-1:
                result += starMap[i].manhattan(starMap[j])

    part 1, 10077850:
        starMap.expand(1).combSums

    part 2, 504715068438:
        starMap.expand(1_000_000-1).combSums
