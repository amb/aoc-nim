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

grid[endLoc] = 'z'-'a'+1

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


# Dijkstra wavefront
var waveFront = [startLoc].toHashSet
var previous = newSeqWith(height, newSeq[(int, int)](width))
for y in 0..<height:
    for x in 0..<width:
        previous[y][x] = (-1, -1)
var step = 0
var traveled = [startLoc].toHashSet
grid[startLoc] = 0
while true:
    var newFront: HashSet[(int, int)]
    for item in waveFront:
        for loc in grid.whereCanGo(item, (a, b) => (a >= b - 1)):
            if loc notin traveled:
                previous[loc] = item
                newFront.incl(loc)
                traveled.incl(loc)
    if newFront.len == 0: break
    waveFront = newFront
    newFront.clear
    inc step

# Track back
var pathBack: seq[(int, int)]
var head = endLoc
while head != startLoc:
    pathBack.add(head)
    head = previous[head]

# Print path back and map
var drawTv = newSeqWith(height, newSeq[char](width))
for y in 0..<height:
    for x in 0..<width:
        drawTv[y][x] = 'a' + grid[y][x]

for t in pathBack: drawTv[t] = ' '

echo collect(for y in 0..<height: 
        collect(for x in 0..<width: 
            drawTv[y][x]).join & "\n").join

assert pathBack.len == pathBack.deduplicate.len
echo pathBack.len