include aoc
import std/[parseutils]
import shadows

day 15:
    type
        Sensor = object
            location: Coord2D
            area: int64

    proc sensorScanline(sensor: Sensor, y: int64): Option[(int64, int64)] =
        let ydisp = abs(sensor.location.y-y)
        if ydisp > sensor.area:
            return none((int64, int64))
        let closeToFringe = (sensor.area-ydisp)
        return some((sensor.location.x - closeToFringe, sensor.location.x + closeToFringe))

    proc findBacon(sensors: seq[Sensor], lval, hval: int64): (int64, int64) =
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

    proc scanLine(sensors: seq[Sensor], lval: int64): int64 =
        var slines: ShadowLines
        for si, s in sensors:
            let r = s.sensorScanline(lval)
            if r.isSome:
                slines.addShadow(r.get)
        slines.finalize()
        for s in 0..<slines.lines.len:
            let sl = slines.lines[s]
            result += (sl.b - sl.a + 1)

    const dscan = "Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i"
    var sensors: seq[Sensor]
    for line in lines:
        var sx, sy, bx, by: int
        if line.scanf(dscan, sx, sy, bx, by):
            let s = coord2d(sx, sy)
            sensors.add(Sensor(location: s, area: s.manhattan(coord2d(bx, by))))

    part 1, 4725496: sensors.scanLine(2000000) - 1
    # part 2, 12051287042458.int64:
    #     let locs = sensors.findBacon(0, 4000000)
    #     locs[0]*4000000+locs[1]
