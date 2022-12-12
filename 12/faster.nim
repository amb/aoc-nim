include ../aoc
import std/[monotimes, times]

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

const dirs: array[4, (int, int)] = [(-1,0),(1,0),(0,1),(0,-1)]
var mask = newSeqWith(height, newSeq[int](width))

grid[endLoc] = 'z'
grid[startLoc] = 'a'

# Dijkstra wavefront
proc forwardWavefront(grd: seq[seq[char]], mask: var seq[seq[int]], sLoc: (int, int), eLoc: (int, int)): int =
    var waveFront = @[sLoc]
    var newFront: seq[(int, int)]
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
                if not (loc[0] < 0 or loc[1] < 0 or loc[0] >= height or loc[1] >= width or 
                grd[item].ord - grd[loc].ord < -1) and mask[loc] != 1:
                    newFront.add(loc)
                    mask[loc] = 1
        waveFront.setLen(0)
        for it in newFront:
            waveFront.add(it)
    step

var timeStart = getMonoTime()

let pathLens = collect:
    for i in 0..<height:
        for y in 0..<height:
            for x in 0..<width:
                mask[y][x] = 0
        forwardWavefront(grid, mask, (i, 0), endLoc)

let answer = min(pathLens)

let mstime = (getMonoTime() - timeStart).inMicroseconds
let mlsecs = mstime div 1000
let mcsecs = mstime - (mlsecs * 1000)
echo "Time: ", mlsecs,".", mcsecs, " ms"

echo answer