include ../aoc
import std/[parseutils, heapqueue]
import kdtree

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
proc sensorScanline(sid: int, y: int): (int, int) =
    let sensor = sensors[sid]
    let ydisp = abs(sensor.location.y-y)
    if ydisp > sensor.area:
        return (-1, -1)
    let closeToFringe = (sensor.area-ydisp)
    return (sensor.location.x - closeToFringe, sensor.location.x + closeToFringe)

proc addShadow(segs: seq[(int, int)], seg: (int, int)): seq[(int, int)] =
    var matchingFirst = -1
    var matchingLast = -1
    var finalSeg = seg
    var isContained = false
    for si, s in segs:
        if (finalSeg[0] <= s[1] and finalSeg[0] >= s[0] and s[1] <= finalSeg[1]):
            # Touching from left side
            assert matchingFirst == -1
            matchingFirst = si
            finalSeg[0] = s[0]
            echo s, " -> ", finalSeg
    
        elif (finalSeg[1] <= s[1] and finalSeg[1] >= s[0] and s[0] >= finalSeg[0]):
            # Touching from right side
            assert matchingLast == -1
            matchingLast = si
            finalSeg[1] = s[1]
            echo s, " -> ", finalSeg

        elif (finalSeg[1] >= s[1] and finalSeg[0] <= s[0]):
            # Seg inside finalseg
            echo "inside: ", s
            discard

        elif (finalSeg[1] <= s[1] and finalSeg[0] >= s[0]):
            # FinalSeg inside seg
            echo "contained: ", s
            isContained = true
            result.add(s)
        
        else:
            # Completely outside
            result.add(s)

    if not isContained:
        result.add(finalSeg)

# For a row in loc y, how many unscanned places?
proc processRow(y: int): seq[(int, int)] =
    for si, s in sensors:
        let r = sensorScanline(si, y)
        if r != (-1, -1):
            echo "n: ", r
            result = result.addShadow(r)
            echo result

# TODO: doesn't handle the cases of beacons in the same row
# let rw = processRow(10)
let rw = processRow(2000000)

# Counted manually 8 beacons that are at the same location on row 2M
echo rw.mapIt(it[1]-it[0]+1).sum-1

# Part 1
# 4917958 too high
# 4725489 too low
# 4725496 was right