include ../aoc
import nanim
import bitty

func `[]`*(b: BitArray2d, v: Vec2i): bool = b[v.y, v.x]
func `[]=`*(b: BitArray2d, v: Vec2i, o: bool) = b[v.y, v.x] = o

let scans = "14/input".readFile.strip.splitLines.mapIt(it.ints.partition(2).mapIt(it.vec2i))

var maxV = vec2i(int.low, int.low)
var minV = vec2i(int.high, int.high)
for d in scans:
    for v in d:
        maxV = max(v, maxV)
        minV = min(v, minV)

minV.y = 0
echo maxV, " ", minV
let groundSize = maxV-minV + vec2i(1, 1)
echo "size: ", groundSize

var ground = newBitArray2D(groundSize.x, groundSize.y)
for scan in scans:
    var loc = scan[0]
    for scanLoc in scan[1..^1]:
        let line = scanLoc - loc
        for _ in 0..<line.len:
            ground[loc - minV] = true
            loc += line.sgn
        ground[loc - minV] = true

var walls = ground.deepCopy

proc printGround() = echo ($ground).replace('0', '.').replace('1', '#')
proc gridToLoc(v: Vec2i): Vec2i = v - groundSize/2

proc gridToCoords(gd: BitArray2d): seq[Vec2i] =
    collect:
        for x in 0..<groundSize.x: 
            for y in 0..<groundSize.y:
                if gd[y, x]: gridToLoc(vec2i(x, y))

var inBounds = true

proc oob(v: Vec2i): bool = v.x < minV.x or v.y < minV.y or v.x > maxV.x or v.y > maxV.y
proc empty(v: Vec2i): bool = return not ground[v-minV]
proc place(v: Vec2i) = ground[v-minV] = true
proc tryMove(v: var Vec2i, move: Vec2i): bool =
    if oob(v+move):
        inBounds = false
        return false
    if (v+move).empty:
        v+=move
        return true
    return false

# Nanim stuff https://github.com/EriKWDev/nanim
let scene = newScene()
scene.width = 660
scene.height = 1200

let colWall = newColor("#2c6494")
let colSand = newColor("#663333")

let wlocs = gridToCoords(walls)
for i in 0..<wlocs.len:
    var nc = newSquare(side=10)
    nc.fill(colWall)
    let loc = wlocs[i]*10
    nc.move(loc.x.float+500, loc.y.float+500)
    scene.add(nc)

var grains: seq[Circle]

# var nc = newCircle(radius=5)
# nc.fill(colSand)
# nc.move((glocs[i][0]*10).float+500, (glocs[i][1]*10).float+500)
# scene.add(nc)

defaultEasing = linear
defaultDuration = 50.0
var count = 0
while inBounds:
    # defaultDuration = 1.0 + pow((float(abs(122-count)) / 122.0), 5.0) * 10.0
    var nc = newCircle(radius=5)
    nc.fill(colSand)
    scene.add(nc)

    var gloc = vec2i(500-minV.x, 0).gridToLoc * 10
    nc.moveTo(gloc.x.float+500, gloc.y.float+500)

    var moves: seq[Tween]

    var loc = vec2i(500, 0)
    while true:
        if loc.tryMove(vec2i(0, 1)):
            moves.add(nc.move(0, 10))
            continue
        if loc.tryMove(vec2i(-1, 1)): 
            moves.add(nc.move(-10, 10))
            continue
        if loc.tryMove(vec2i(1, 1)): 
            moves.add(nc.move(10, 10))
            continue
        break

    # echo moves.len
    scene.animate(moves)
    loc.place
    inc count

# printGround()
echo count-1
# 244 too low, 833 too high

when isMainModule:
    render(scene)