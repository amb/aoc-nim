include ../aoc
import ../tracer
import std/[parseutils, heapqueue]
import kdtree
import shadows

type
    Sensor = object
        location: Vec2i
        area: int

# Parse data
const dscan = "Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i"
var sensors: seq[Sensor]
var beacons: seq[Vec2i]
for line in "15/input".lines:
    var sx, sy, bx, by: int
    if line.scanf(dscan, sx, sy, bx, by):
        let s = vec2i(sx, sy)
        let b = vec2i(bx, by)
        sensors.add(Sensor(location: s, area: s.manhattan(b)))
        beacons.add(b)

# Create KD-tree from data
proc manhattanKD(x, y: KdPoint): float = abs(x[0]-y[0])+abs(x[1]-y[1])
var tree = newKDTree[Vec2i](beacons.mapIt(it.asFloatArray), beacons, distFunc=manhattanKD)

# Check everything is good
for si, s in sensors:
    let treeres = tree.nearestNeighbour([s.location.x.float, s.location.y.float])
    assert treeres[1] == beacons[si]
    assert treeres[2].int == s.area

# Start building shadowlines
proc sensorScanline(sid: int, y: int): (int, int) {.meter.} =
    let sensor = sensors[sid]
    let ydisp = abs(sensor.location.y-y)
    if ydisp > sensor.area:
        return (1, -1)
    let closeToFringe = (sensor.area-ydisp)
    return (sensor.location.x - closeToFringe, sensor.location.x + closeToFringe)

proc findBacon(lval, hval: int): (int, int) {.meter.} =
    var slines: ShadowLines
    for ri in 0..hval:
        for si, s in sensors:
            let r = sensorScanline(si, ri)
            if r != (1, -1):
                slines.addShadow(r)
        slines.finalize()
        for e in slines.empties(lval, hval):
            if e[1]-e[0] > 1:
                return (e[0]+1, ri)
        slines.reset()

metricsConfirm()

echo "----- BACON"
let locs = findBacon(0, 4000000)
# let locs = findBacon(0, 20)
let answer = locs[0]*4000000+locs[1]
assert answer == 12051287042458
echo locs
echo answer

metricsShow()
