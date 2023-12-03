import ../aoc
import std/[sequtils, strutils, sets, tables, math]

day 3:
    let lines = input.splitLines
    let (w, h) = lines.dims

    let gridNumbers = lines.toCoords2D(proc (c: char): bool = c.isDigit)
    let gridSymbols = lines.toCoords2D(proc (c: char): bool = (not c.isDigit) and (c != '.'))

    var start = gridSymbols.grow & gridNumbers
    start = start.grow(gridNumbers)
    start = start.grow(gridNumbers)
    let eparts = gridNumbers & start

    proc parseNums(na: Coords2D): (seq[int], Table[Coord2D, int]) =
        var numberMap = initTable[Coord2D, int]()
        var accum: seq[char]
        for y in 0 ..< h:
            for x in 0 ..< w + 1:
                if na.contains(coord2D(x, y)):
                    accum.add(lines[y][x])
                elif accum.len > 0:
                    let val = parseInt(accum.join)
                    for l in 1..accum.len:
                        numberMap[coord2D(x-l, y)] = val
                    result[0].add(val)
                    accum = @[]
        result[1] = numberMap

    part 1, 546312:
        parseNums(eparts)[0].sum

    part 2, 87449461:
        let gears = lines.toCoords2D(proc (c: char): bool = c == '*')
        let nn = gridNumbers
        let numberMap = parseNums(nn)[1]
        var total = 0
        for g in gears:
            var nums: seq[int]
            var count = 0

            proc cinc(x, y: int): bool =
                if g+(x, y) in nn:
                    nums.add(numberMap[g+(x, y)])
                    inc count
                    true
                else:
                    false

            discard cinc(-1,0)
            discard cinc(1,0)       

            if not cinc(0,-1):
                discard cinc(-1,-1)
                discard cinc(1,-1)

            if not cinc(0,1):
                discard cinc(-1,1)
                discard cinc(1,1)

            # echo nums
            if nums.len == 2:
                total += nums[0] * nums[1]
        total
