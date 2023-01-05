include aoc
import std/[enumerate]

let test = """
        ...#
        .#..
        #...
        ....
...#.......#
........#...
..#....#....
..........#.
        ...#....
        .....#..
        .#......
        ......#.

10R5L5R10L4R5L5"""

let data = "22/input".readFile.split("\n\n")

var movements: seq[(int, char)]
for r in data[1].findAll(re.re"\d+\w"):
    let tp = (if r[^1].isAlphaAscii: (r[0..^2], r[^1]) else: (r, ' '))
    movements.add((tp[0].parseInt, tp[1]))

# Parsing
let lines = data[0].splitLines
var walls = lines.toCoords2D('#') + (1, 1)
var ground = (lines.toCoords2D('.') + (1, 1)) + walls

# Initially facing right
var facing = vec2i(1, 0)
var location = vec2i((ground.toSeq.filterIt(it[1] == 1).min)[0], 1)
var borders = ground.neighbours
for step in movements:
    for _ in 1..step[0]:
        var newLoc = location + facing
        if newLoc.asTuple in borders:
            while true:
                newLoc -= facing
                if newLoc.asTuple in borders:
                    break
            newLoc += facing
        if newLoc.asTuple in walls:
            break
        location = newLoc

    facing = rot90(facing, int(step[1]=='R') - int(step[1]=='L'))

# P1: 181128 correct
echo location.y * 1000 + location.x * 4 + [(-1,0), (0,1), (-1,0), (0,-1)].find(facing) + 1

let cube = """
 12
 3
45
6
"""

# Rotation 90 degrees vector comes from cross product of direction and cube face normal

