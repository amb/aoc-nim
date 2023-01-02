include ../aoc
import std/[parseutils, options]
import shadows

type
    Sensor = object
        location: Vec2i
        area: int

proc sensorScanline(sensor: Sensor, y: int): Option[(int, int)] =
    let ydisp = abs(sensor.location.y-y)
    if ydisp > sensor.area:
        return none((int, int))
    let closeToFringe = (sensor.area-ydisp)
    return some((sensor.location.x - closeToFringe, sensor.location.x + closeToFringe))

proc findBacon(sensors: seq[Sensor], lval, hval: int): (int, int) =
    var slines: ShadowLines
    for ry in 0..hval:
        for si, s in sensors:
            let r = s.sensorScanline(ry)
            if r.isSome:
                slines.addShadow(r.get)
        slines.finalize()
        for e in slines.empties(lval, hval):
            if e[1]-e[0] > 1:
                return (e[0]+1, ry)
        slines.reset()

const dscan = "Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i"
var sensors: seq[Sensor]
for line in "15/input".lines:
    var sx, sy, bx, by: int
    if line.scanf(dscan, sx, sy, bx, by):
        let s = vec2i(sx, sy)
        sensors.add(Sensor(location: s, area: s.manhattan(vec2i(bx, by))))


aocIt "Part 2", 12051287042458.int: 
    let locs = sensors.findBacon(0, 4000000)
    locs[0]*4000000+locs[1]
