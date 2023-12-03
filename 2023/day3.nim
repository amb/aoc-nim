import ../aoc
import std/[sequtils, strutils, tables, math, intsets]

day 3:
    let lines = input.splitLines
    let (w, h) = lines.dims

    const DIRS = [(-1, 0), (1, 0), (0, -1), (0, 1), 
                (-1, -1), (1, 1), (1, -1), (-1, 1)]

    proc read(ar: seq[string], loc: (int, int)): char =
        let (x, y) = loc
        if x >= 0 and x < w and y >= 0 and y < h:
            return ar[y][x]
        return '.'

    proc readIds(at: Table[(int, int), (int, int)], loc: (int, int)): IntSet =
        for pos in DIRS:
            if loc + pos in at:
                # ASSUMPTION: numbers are unique
                result.incl(at[loc + pos][1])

    var numberMap = initTable[(int, int), (int, int)]()
    var eng_parts: seq[int]
    var accum: seq[char]
    var symbolsFlag = false
    var counter = 0
    for y in 0 ..< h:
        for x in 0 ..< w + 1:
            if lines.read((x, y)).isDigit:
                accum.add(lines[y][x])
                for loc in DIRS:
                    let rc = lines.read(loc + (x, y))
                    if rc != '.' and not rc.isDigit:
                        symbolsFlag = true

            elif accum.len > 0:
                let val = parseInt(accum.join)
                for l in 1..accum.len:
                    numberMap[(x-l, y)] = (counter, val)

                if symbolsFlag:
                    eng_parts.add(val)
                
                inc counter
                accum.setLen(0)
                symbolsFlag = false

    part 1, 546312: eng_parts.sum

    part 2, 87449461:
        var total = 0
        for y in 0 ..< h:
            for x in 0 ..< w:
                if lines[y][x] == '*':
                    let gval = numberMap.readIds((x, y)).toSeq
                    if gval.len == 2:
                        total += gval[0] * gval[1]
        total
