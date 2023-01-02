include ../aoc
import std/[monotimes, times]

var timeStart = getMonoTime()

let data = "12/input".readFile.strip.splitLines

# grid[rows][columns]
var startLoc, endLoc: (int, int)
var grid = collect:
    for y, line in data:
        collect:
            for x, c in line:
                if c=='S': startLoc = (y, x)
                if c=='E': endLoc = (y, x)
                c

let height = grid.len
let width = grid[0].len
echo fmt"width: {width}, height: {height}"
echo fmt"start: {startLoc}, end: {endLoc}"
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

let pathLens = collect:
    for i in 0..<height:
        forwardWavefront(grid, (i, 0), endLoc)

echo pathLens
echo min(pathLens)

let mstime = (getMonoTime() - timeStart).inMicroseconds
let mlsecs = mstime div 1000
let mcsecs = mstime - (mlsecs * 1000)
echo "Time: ", mlsecs,".", mcsecs, " ms"

# # Track back
# var pathBack: seq[(int, int)]
# var head = endLoc
# while head != startLoc:
#     head = previous[head]
#     pathBack.add(head)

# echo pathBack.len

# # Print path back and map
# var drawTv = deepCopy grid
# for t in pathBack: drawTv[t] = ' '

# echo collect(for y in 0..<height:
#         collect(for x in 0..<width:
#             drawTv[y][x]).join & "\n").join

# assert pathBack.len == pathBack.deduplicate.len
# echo pathBack.len
