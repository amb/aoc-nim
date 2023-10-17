include aoc
import std/parseutils
import shadows

day 15:
    type
        Sensor = object
            location: Coord2D
            area: int

    proc sensorScanline(sensor: Sensor, y: int64): Option[(int64, int64)] =
        let ydisp = abs(sensor.location.y-y)
        if ydisp > sensor.area:
            return none((int64, int64))
        let closeToFringe = (sensor.area-ydisp)
        return some((sensor.location.x - closeToFringe, sensor.location.x + closeToFringe))

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

    # 1. an isolated cell can only appear in the gap between two parallel lines with distance 2 between
    # 2. in fact 2 sets of parallel lines, one pair in the / direction and one pair in the \ direction
    # 3. so if you find such an arrangement in the / and \ direction, their intersections gives you the only possible candidates for such a location
    # 4. this solution only scales with the number of lines of input

    proc atZero(o: Coord2D, v: Coord2D, area, s: int): int =
        # s=-1 => /, s=1  => \
        o.y + (o.x + area * v.sgn.x + v.sgn.x) * s

    # Get all sensors where there's 1 space in between
    var y0, y1: int64
    for y in 0..<sensors.len:
        for x in y+1..<sensors.len:
            let sy = sensors[y]
            let sx = sensors[x]
            if sy.location.manhattan(sx.location) == sy.area + sx.area + 2:
                # From sx to sy
                let diff = sy.location - sx.location
                let ds = diff.sgn

                # \ line
                if ds in [coord2d(1, 1), coord2d(-1, -1)]:
                    y0 = atZero(sx.location, diff, sx.area, 1)

                # / line
                if ds in [coord2d(-1, 1), coord2d(1, -1)]:
                    y1 = atZero(sx.location, diff, sx.area, -1)

    # Line equation
    # y1 - x == y2 + x
    # y1-y2 = 2x
    # x = (y1-y2)/2

    part 2, 12051287042458.int64:
        let x = (y0-y1) div 2
        x*4000000+y1+x
