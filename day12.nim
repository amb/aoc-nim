include aoc

day 12:
    # grid[rows][columns]
    var startLoc, endLoc: (int, int)
    var grid = collect:
        for y, line in lines:
            collect:
                for x, c in line:
                    if c=='S': startLoc = (y, x)
                    if c=='E': endLoc = (y, x)
                    c

    let height = grid.len
    let width = grid[0].len

    # echo fmt"width: {width}, height: {height}"
    # echo fmt"start: {startLoc}, end: {endLoc}"

    grid[endLoc] = 'z'
    grid[startLoc] = 'a'

    proc neighbours(l: (int, int)): seq[(int, int)] =
        let ly= l[0]
        let lx = l[1]
        @[(ly-1, lx), (ly+1, lx), (ly, lx-1), (ly, lx+1)]

    proc directions(grd: seq[seq[char]], loc: (int, int),
        test: proc (a: char, b: char): bool): seq[(int, int)] =
        let grw = grd[0].len
        let grh = grd.len
        collect:
            for (y, x) in loc.neighbours:
                if y >= 0 and x >= 0 and y < grh and x < grw:
                    if test(grd[loc], grd[y][x]):
                        (y, x)

    # Dijkstra wavefront
    proc forwardWavefront(grd: seq[seq[char]], sLoc: (int, int), eLoc: (int, int)): int =
        var previous = {sLoc: sLoc}.toTable
        var waveFront = [sLoc].toHashSet
        var newFront: HashSet[(int, int)]
        var step = 0
        while true:
            for item in waveFront:
                for loc in grd.directions(item, (a, b) => (a.ord >= b.ord - 1)):
                    if loc notin previous:
                        previous[loc] = item
                        newFront.incl(loc)
            inc step
            if newFront.len == 0 or eLoc in newFront: break
            waveFront = newFront
            newFront.clear
        step

    part 1, 497:
        forwardWavefront(grid, startLoc, endLoc)

    part 2, 492: 
        # TODO: this is inefficient
        let pathLens = collect:
            for i in 0..<height:
                forwardWavefront(grid, (i, 0), endLoc)
        min(pathLens)
