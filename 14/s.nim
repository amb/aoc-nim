include ../aoc
import nanim
import bitty

func `[]`*(b: BitArray2d, v: Coord2D): bool = b[v.y, v.x]
func `[]=`*(b: BitArray2d, v: Coord2D, o: bool) = b[v.y, v.x] = o

let scans = "14/input".readFile.strip.splitLines.mapIt(it.ints.partition(2).mapIt(it.coord2d))

var maxV = coord2d(int.low, int.low)
var minV = coord2d(int.high, int.high)
for d in scans:
    for v in d:
        maxV = max(v, maxV)
        minV = min(v, minV)

minV.y = 0
echo maxV, " ", minV
var grSize = maxV-minV + coord2d(1, 1)

let displace = coord2d(grSize.y-1, 0)
var ground = newBitArray2D(grSize.x + displace.x*2, grSize.y + 2)
grSize = coord2d(grSize.x + displace.x*2, grSize.y + 2)
echo "size: ", grSize

for scan in scans:
    var loc = scan[0]
    for scanLoc in scan[1..^1]:
        let line = scanLoc - loc
        for _ in 0..<line.len:
            ground[loc - minV + displace] = true
            loc += line.sgn
        ground[loc - minV + displace] = true

for i in 0..<grSize.x:
    ground[grSize.y-1, i] = true

var walls = ground.deepCopy

const vMulti = 5

proc printGround() = echo ($ground).replace('0', '.').replace('1', '#')
proc gridToLoc(v: Coord2D): Coord2D = (v - grSize/2) * vMulti + coord2d(500, 500)

proc gridToCoords(gd: BitArray2d): seq[Coord2D] =
    collect:
        for x in 0..<grSize.x: 
            for y in 0..<grSize.y:
                if gd[y, x]: gridToLoc(coord2d(x, y))

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

let scene = newScene()
# scene.width = 1200
# scene.height = 800

let colWall = newColor("#2c6494")
let colSand = newColor("#663333")

let wlocs = gridToCoords(walls)
for i in 0..<wlocs.len:
    var nc = newSquare(side=vMulti)
    nc.fill(colWall)
    let loc = wlocs[i]
    nc.move(loc.x.float, loc.y.float)
    scene.add(nc)

defaultEasing = (t: float) => (if t < 0.5: 0.0 else: 1.0)
defaultDuration = 0.02
var count = 0
let sandSpawnerLoc = coord2d(500-minV.x+displace.x, 0)
while inBounds:
    var loc = sandSpawnerLoc
    while true:
        if loc.tryMove(coord2d(0, 1)): continue
        if loc.tryMove(coord2d(-1, 1)): continue
        if loc.tryMove(coord2d(1, 1)): continue
        break

    var gloc = loc.gridToLoc
    var nc = newCircle(radius=vMulti div 2)
    nc.fill(colSand)
    scene.add(nc)
    nc.position = vec3(gloc.x.float, 0.0, 0.0)
    scene.play(nc.moveTo(gloc.x.float, gloc.y.float))

    loc.place
    inc count
    if loc == sandSpawnerLoc:
        break
    if count > 300000:
        break

# printGround()
echo count
# Part 1: 832
# Part 2: 27601

render(scene)
# nim c -d:release -d:strip 14\s.nim && 14\s.exe --debug:off -v