include ../aoc

let test = """
Sabqponm
abcryxxl
accszExk
acctuvwj
abdefghi
"""

let data = readFile("12/input").strip.splitLines
# let data = test.strip.splitLines

# grid[rows][columns]
var startLoc, endLoc: (int, int)
var grid = collect:
    for y, line in data:
        collect:
            for x, c in line:
                if c-'a' == -14: startLoc = (y, x)
                if c-'a' == -28: endLoc = (y, x)
                c-'a'

let height = grid.len
let width = grid[0].len
echo fmt"width: {width}, height: {height}"
echo fmt"start: {startLoc}, end: {endLoc}"

proc printGrid(gd: seq[seq[int]]): string =
    collect(for y in 0..<gd.len:
        let row = collect(for x in 0..<gd[0].len: 'a'+gd[y][x]).join
        row & "\n").join

var waveFront = [startLoc].toHashSet
var distanceGrid = newSeqWith(height, newSeq[int](width))
for y in 0..<height:
    for x in 0..<width:
        distanceGrid[y][x] = int.high

proc inGrid(loc: (int, int), grd: seq[seq[int]]): bool =
    let x = loc[1]
    let y = loc[0]
    let grw = grd[0].len
    let grh = grd.len
    y >= 0 and x >= 0 and y < grh and x < grw

proc neighbours(l: (int, int)): seq[(int, int)] =
    let ly= l[0]
    let lx = l[1]
    @[(ly-1, lx), (ly+1, lx), (ly, lx-1), (ly, lx+1)]

proc whereCanGo(grd: seq[seq[int]], loc: (int, int),
    test: proc (a: int, b: int): bool): seq[(int, int)] =
    let tv = grd[loc]
    let grw = grd[0].len
    let grh = grd.len
    collect:
        for (y, x) in loc.neighbours:
            if y >= 0 and x >= 0 and y < grh and x < grw:
                if test(tv, grd[y][x]):
                    (y, x)

# echo grid.printGrid

# Dijkstra wavefront
var step = 0
var traveled = [startLoc].toHashSet
grid[endLoc] = int.high
grid[startLoc] = 0
while true:
    var newFront: HashSet[(int, int)]
    for item in waveFront:
        distanceGrid[item] = step
        # -28 = endloc value
        for (y, x) in grid.whereCanGo(item, (a, b) => (a == b - 1 or a == b or b == -28)):
            if (y, x) notin traveled:
                newFront.incl((y, x))
                traveled.incl((y, x))
    if newFront.len == 0: break
    waveFront = newFront
    newFront.clear
    inc step

echo "Steps: ", step
doAssert step > 0

var drawTv = newSeqWith(height, newSeq[char](width))
for y in 0..<height:
    for x in 0..<width:
        drawTv[y][x] = '.'
for t in traveled:
    drawTv[t] = '#'
echo collect(for y in 0..<height: collect(for x in 0..<width: drawTv[y][x]).join & "\n").join


# Track back
var pathBack = @[endLoc]
distanceGrid[endLoc] = collect(
    for l in endLoc.neighbours.filterIt(it.inGrid(grid)): 
        distanceGrid[l]).max + 1

while distanceGrid[pathBack[^1]] > 0:
    var loc = pathBack[^1]
    var value = distanceGrid[loc]
    let lookHere = loc.neighbours.filterIt(it.inGrid(grid))
    let floc = lookHere.findFirst(x => distanceGrid[x] == value - 1)
    if not floc.isSome:
        echo "broke"
        break
    pathBack.add(floc.get)

echo pathBack
echo pathBack.len - 1