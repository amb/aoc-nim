include aoc
import bitty

func `[]`(b: BitArray2d, v: Vec2i): bool = b[v.y, v.x]
func `[]=`(b: BitArray2d, v: Vec2i, o: bool) = b[v.y, v.x] = o

day 14:
    let scans = lines.mapIt(it.ints.partition(2).mapIt(it.vec2i))

    var maxV = vec2i(int.low, int.low)
    var minV = vec2i(int.high, int.high)
    for d in scans:
        for v in d:
            maxV = max(v, maxV)
            minV = min(v, minV)

    minV.y = 0
    var grSize = maxV-minV + vec2i(1, 1)

    let displace = vec2i(grSize.y-1, 0)
    var groundInit = newBitArray2D(grSize.x + displace.x*2, grSize.y + 2)
    grSize = vec2i(grSize.x + displace.x*2, grSize.y + 2)

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

        var walls = ground.deepCopy
        var inBounds = true

        proc oob(v: Vec2i): bool = v.x < 0 or v.y < 0 or v.x >= grSize.x or v.y >= grSize.y
        proc empty(v: Vec2i): bool = return not ground[v]
        proc place(v: Vec2i) = ground[v] = true
        proc tryMove(v: var Vec2i, move: Vec2i): bool =
            let nextLoc = v+move
            if nextLoc.oob:
                inBounds = false
                return false
            if nextLoc.empty:
                v+=move
                return true
            return false

        var count = 0
        let sandSpawnerLoc = vec2i(500-minV.x+displace.x, 0)
        while inBounds:
            var loc = sandSpawnerLoc
            while true:
                if loc.tryMove(vec2i(0, 1)): continue
                if loc.tryMove(vec2i(-1, 1)): continue
                if loc.tryMove(vec2i(1, 1)): continue
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
