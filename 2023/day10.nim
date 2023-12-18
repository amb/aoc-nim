import ../aoc
import ../coords
import std/[sequtils, strutils, enumerate, tables, sets, math, options, strformat]

day 10:
    var lines = input.splitLines

    proc printPipes(trv: Table[Coord2D, int]) =
        for li, l in lines:
            for ci, c in l:
                if c == 'S' or c == 'X':
                    stdout.write(red($c))
                elif (ci, li) in trv:
                    stdout.write(rgbText($c, 128, (trv[(ci, li)]*255 div 15000).floorMod(256), 64))
                else:
                    stdout.write(grey($c))
            echo ""

    type Direction = enum Up, Left, Right, Down

    let pipes: Table[char, seq[Direction]] = {
        '|': @[Up, Down],
        '-': @[Left, Right],
        'L': @[Up, Right],
        'J': @[Left, Up],
        '7': @[Left, Down],
        'F': @[Right, Down],
        '.': @[],
        'S': @[Up, Left, Right, Down]
    }.toTable

    proc getSymbol(loc: Coord2D): char =
        if loc.x < 0 or loc.y < 0 or loc.y >= lines.len or loc.x >= lines[0].len:
            return ' '
        else:
            return lines[loc.y][loc.x]

    part 1, 7063:
        var startLoc: Coord2D
        for li, l in lines:
            for ci, c in enumerate(l):
                if c == 'S':
                    startLoc = coord2d(ci, li)
                    break
        echo "start at: ", startLoc

        proc move(loc: Coord2D, dir: Direction): Option[Coord2D] =
            let newLoc = case dir:
                of Left:  (loc.x - 1, loc.y)
                of Up:    (loc.x, loc.y - 1)
                of Down:  (loc.x, loc.y + 1)
                of Right: (loc.x + 1, loc.y)

            if newLoc.x < 0 or newLoc.y < 0 or newLoc.y >= lines.len or newLoc.x >= lines[0].len:
                return none(Coord2D)
            else:
                return some(newLoc)

        var traveled: Table[Coord2D, int]
        traveled[startLoc] = 0

        # TODO: finish this
        proc getAvailableLocation(loc: Coord2D): Option[Coord2D] =
            const tests = ["|7F", "-LF", "-J7", "L|J"]
            result = none(Coord2D)
            for d in pipes[getSymbol(loc)]:
                let newLoc = move(loc, d)
                if newLoc.isSome and newLoc.get() notin traveled and getSymbol(newLoc.get()) in tests[d.ord]:
                    assert result.isNone, fmt"symbol {getSymbol(loc)} at {loc} has multiple valid directions"
                    result = some(newLoc.get())

        # generate start heads
        var heads: seq[Option[Coord2D]]
        for e in Direction:
            let nh = startLoc.move(e)
            if nh.isSome:
                let sym = getSymbol(nh.get())
                if (e == Up and sym in "J-L") or
                   (e == Down and sym in "7-F") or
                   (e == Left and sym in "J|7") or
                   (e == Right and sym in "F|L"):
                    continue

                heads.add(some(nh.get()))
                traveled[nh.get()] = 1

        echo "heads: ", heads.len

        var step = 1
        var furthestLoc = startLoc
        for i in 0..500_000:
            var alive = 0
            for hi, h in heads:
                if h.isNone:
                    continue
                # stdout.write(getSymbol(h.get()))
                let newLoc = getAvailableLocation(h.get())
                if newLoc.isSome:
                    traveled[newLoc.get()] = step
                    heads[hi] = some(newLoc.get())
                    inc alive
                else:
                    heads[hi] = none(Coord2D)

            if alive == 1:
                for h in heads:
                    if h.isSome:
                        furthestLoc = h.get()
                        break

            if alive == 0:
                break

            inc step

        echo "old char: ", getSymbol(furthestLoc)
        lines[furthestLoc.y][furthestLoc.x] = 'X'
        echo "end at: ", furthestLoc

        # printPipes(traveled)

        step

        # 7053 too low
        # 7054 too low
        # 14104 too high
        # 14105 too high

    part 2:
        404
