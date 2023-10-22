import aoc
import strutils, tables

day 12:
    let data = lines
    let height = data.len
    let width = data[0].len
    let asize = height * width

    # grid[rows][columns]
    var startLoc, endLoc: int
    var grid = newSeq[char](asize)
    for y, line in data:
        for x, c in line:
            if c == 'S': startLoc = y*width+x
            if c == 'E': endLoc = y*width+x
            grid[x+y*width] = c

    let dirs: array[4, int] = [-1, 1, width, -width]
    var mask = newSeq[int](asize)

    grid[endLoc] = 'z'
    grid[startLoc] = 'a'

    # Dijkstra wavefront
    proc forwardWavefront(grd: seq[char], mask: var seq[int], sLoc: int, eLoc: int): int =
        var waveFront = @[sLoc]
        var newFront: seq[int]
        var step = 0
        while waveFront.len > 0:
            inc step
            newFront.setLen(0)
            for item in waveFront:
                if item == eLoc:
                    return step-1
                mask[item] = 1
                for d in dirs:
                    let loc = item + d
                    if loc >= 0 and loc < asize and
                    grd[item].ord - grd[loc].ord >= -1 and mask[loc] != 1:
                        newFront.add(loc)
                        mask[loc] = 1
            waveFront.setLen(0)
            for it in newFront:
                waveFront.add(it)
        step

    part 1, 497:
        forwardWavefront(grid, mask, startLoc, endLoc)

    part 2, 492:
        # TODO: this is inefficient
        var minVal = int.high
        for i in 0..<height:
            for s in 0..<asize: mask[s] = 0
            minVal = min(minVal, forwardWavefront(grid, mask, i*width, endLoc))
        minVal
