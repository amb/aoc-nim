include ../aoc
import std/parseutils

type
    Sensor = object
        location: Vec2i
        area: int

const dscan = "Sensor at x=$i, y=$i: closest beacon is at x=$i, y=$i"
var sensors: seq[Sensor]
for line in "15/input".lines:
    var sx, sy, bx, by: int
    if line.scanf(dscan, sx, sy, bx, by):
        let s = vec2i(sx, sy)
        sensors.add(Sensor(location: s, area: s.manhattan(vec2i(bx, by))))

# 1. an isolated cell can only appear in the gap between two parallel lines with distance 2 between
# 2. in fact 2 sets of parallel lines, one pair in the / direction and one pair in the \ direction
# 3. so if you find such an arrangement in the / and \ direction, their intersections gives you the only possible candidates for such a location
# 4. this solution only scales with the number of lines of input

let (yz0, yz1) = oneTimeIt:
    proc atZero(o: Vec2i, v: Vec2i, area, s: int): int =
        var pt = o
        pt.x += area * v.sgn.x + v.sgn.x
        # s=-1 => /, s=1  => \
        pt.y + pt.x * s

    # Get all sensors where there's 1 space in between
    var y0, y1: int
    for y in 0..<sensors.len:
        for x in y+1..<sensors.len:
            let sy = sensors[y]
            let sx = sensors[x]
            if sy.location.manhattan(sx.location) == sy.area + sx.area + 2:
                # From sx to sy
                let diff = sy.location - sx.location
                let ds = diff.sgn
                
                # \ line
                if ds in [vec2i(1, 1), vec2i(-1, -1)]:
                    y0 = atZero(sx.location, diff, sx.area, 1)

                # / line
                if ds in [vec2i(-1, 1), vec2i(1, -1)]:
                    y1 = atZero(sx.location, diff, sx.area, -1)
    (y0, y1)

echo "A: ", yz0
echo "B: ", yz1

# Line equation
# y1 - x == y2 + x
# y1-y2 = 2x
# x = (y1-y2)/2

let x = (yz0-yz1) div 2
# echo (x, yz1 + x)
echo x*4000000+yz1+x
