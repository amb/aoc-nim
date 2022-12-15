include ../aoc
# import ../tracer
import std/parseutils
import shadows

type
    Sensor = object
        location: Vec2i
        area: int

proc sensorScanline(sensor: Sensor, sid: int, y: int): (int, int) =
    let ydisp = abs(sensor.location.y-y)
    if ydisp > sensor.area:
        return (1, -1)
    let closeToFringe = (sensor.area-ydisp)
    return (sensor.location.x - closeToFringe, sensor.location.x + closeToFringe)

proc findBacon(sensors: seq[Sensor], lval, hval: int): (int, int) =
    var slines: ShadowLines
    for ri in 0..hval:
        for si, s in sensors:
            let r = s.sensorScanline(si, ri)
            if r != (1, -1):
                slines.addShadow(r)
        slines.finalize()
        for e in slines.empties(lval, hval):
            if e[1]-e[0] > 1:
                return (e[0]+1, ri)
        slines.reset()

let timeStart = getMonoTime()

# Parse data
const dscan = "Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i"
var sensors: seq[Sensor]
for line in "15/input".lines:
    var sx, sy, bx, by: int
    if line.scanf(dscan, sx, sy, bx, by):
        let s = vec2i(sx, sy)
        sensors.add(Sensor(location: s, area: s.manhattan(vec2i(bx, by))))

let locs = sensors.findBacon(0, 4000000)

(getMonoTime() - timeStart).prtTime

# let locs = findBacon(0, 20)
let answer = locs[0]*4000000+locs[1]
assert answer == 12051287042458
echo locs
echo answer
