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
        return (-1, -1)
    let closeToFringe = (sensor.area-ydisp)
    return (sensor.location.x - closeToFringe, sensor.location.x + closeToFringe)

# For a row in loc y, how many unscanned places?
proc processRow(y: int): ShadowLines {.meter.} =
    for si, s in sensors:
        let r = sensorScanline(si, y)
        if r != (-1, -1):
            result = result.addShadow(r)

# TODO: super stupid, doesn't actually clip left or right
iterator empties(segs: seq[(int, int)], lval, hval: int): (int, int) =
    var i = 0
    while i < segs.len-1:
        let left = segs[i]
        let right = segs[i+1]
        yield (left[1], right[0])
        inc i

proc findBacon(lval, hval: int): (int, int) {.meter.} =
    for ri in 0..hval:
        var pr = processRow(ri)
        pr.finalize()
        for e in empties(pr.lines, lval, hval):
            if e[1]-e[0] > 1:
                return (e[0]+1, ri)

metricsConfirm()

echo "----- BACON"
let locs = findBacon(0, 4000000)
let answer = locs[0]*4000000+locs[1]
assert answer == 12051287042458
echo answer

metricsShow()
