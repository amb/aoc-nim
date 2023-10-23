import aoc
import sequtils, strutils, tables

import bitty

func `[]`(b: BitArray2d, v: Coord2D): bool = b[v.y, v.x]
func `[]=`(b: BitArray2d, v: Coord2D, o: bool) = b[v.y, v.x] = o

day 14:
    let scans = lines.mapIt(it.ints.partition(2).mapIt(it.coord2d))

    var maxV = coord2d(int.low, int.low)
    var minV = coord2d(int.high, int.high)
    for d in scans:
        for v in d:
            maxV = max(v, maxV)
            minV = min(v, minV)

    minV = (minV.x, 0)
    var grSize = maxV-minV + coord2d(1, 1)

    let displace = coord2d(grSize.y-1, 0)
    var groundInit = newBitArray2D(grSize.x + displace.x*2, grSize.y + 2)
    grSize = coord2d(grSize.x + displace.x*2, grSize.y + 2)

    for scan in scans:
        var loc = scan[0]
        for scanLoc in scan[1..^1]:
            let line = scanLoc - loc
            for _ in 0..<line.len:
                groundInit[loc - minV + displace] = true
                loc += line.sgn
            groundInit[loc - minV + displace] = true

    proc solve(drawFloor = false): int =
        var ground = groundInit.deepCopy

        # Create ground level
        if drawFloor:
            for i in 0..<grSize.x:
                ground[grSize.y-1, i] = true

        # var walls = ground.deepCopy
        var inBounds = true

        proc oob(v: Coord2D): bool = v.x < 0 or v.y < 0 or v.x >= grSize.x or v.y >= grSize.y
        proc empty(v: Coord2D): bool = return not ground[v]
        proc place(v: Coord2D) = ground[v] = true
        proc tryMove(v: var Coord2D, move: Coord2D): bool =
            let nextLoc = v+move
            if nextLoc.oob:
                inBounds = false
                return false
            if nextLoc.empty:
                v+=move
                return true
            return false

        var count = 0
        let sandSpawnerLoc = coord2d(500-minV.x+displace.x, 0)
        while inBounds:
            var loc = sandSpawnerLoc
            while true:
                if loc.tryMove(coord2d(0, 1)): continue
                if loc.tryMove(coord2d(-1, 1)): continue
                if loc.tryMove(coord2d(1, 1)): continue
                break

            loc.place
            inc count
            if loc == sandSpawnerLoc:
                break
            if count > 300000:
                break
        count

    part 1, 832: solve(false)-1
    part 2, 27601: solve(true)
