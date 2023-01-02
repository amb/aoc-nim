include aoc
import std/[parseutils]
import shadows

day 15:
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
        for ry in lval..hval:
            for si, s in sensors:
                let r = s.sensorScanline(ry)
                if r.isSome:
                    slines.addShadow(r.get)
            slines.finalize()
            for e in slines.empties(lval, hval):
                if e[1]-e[0] > 1:
                    return (e[0]+1, ry)
            slines.reset()

    proc scanLine(sensors: seq[Sensor], lval: int): int =
        var slines: ShadowLines
        for si, s in sensors:
            let r = s.sensorScanline(lval)
            if r.isSome:
                slines.addShadow(r.get)
        slines.finalize()
        echo slines.lines.len
        for s in 0..<slines.lines.len:
            let sl = slines.lines[s]
            result += (sl.b - sl.a + 1)

    const dscan = "Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i"
    var sensors: seq[Sensor]
    for line in lines:
        var sx, sy, bx, by: int
        if line.scanf(dscan, sx, sy, bx, by):
            let s = vec2i(sx, sy)
            sensors.add(Sensor(location: s, area: s.manhattan(vec2i(bx, by))))

    part 1, 4725496: sensors.scanLine(2000000) - 1

    part 2, 12051287042458.int:
        let locs = sensors.findBacon(0, 4000000)
        locs[0]*4000000+locs[1]
