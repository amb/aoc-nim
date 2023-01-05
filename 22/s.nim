include ../aoc
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

# let data = test.split("\n\n")

let data = "22/input".readFile.split("\n\n")

var movements: seq[(int, char)]
for r in data[1].findAll(re.re"\d+\w"):
    let tp = (if r[^1].isAlphaAscii: (r[0..^2], r[^1]) else: (r, ' '))
    movements.add((tp[0].parseInt, tp[1]))

# Parsing
var walls: Coords2D
var ground: Coords2D
for li, line in enumerate(data[0].splitLines):
    for ci, c in line:
        let location = (ci+1, li+1)
        if c != ' ':
            ground.incl(location)
            if c == '#':
                walls.incl(location)

# TODO: seq[seq[int]].arrayToSet(7): Coords2D == Coords2D.setToArray(7): seq[seq[int]]

# Solving
let walkable = ground - walls
var borders: Coords2D
for d in Coords2D.faces:
    borders = borders + ((ground + d) - ground)

# Generate path
proc rdir(d: char): int = (if d=='L': -1 elif d=='R': 1 else: 0)

# Find starting position
var x = int.high
for i in ground:
    if i[1] == 1:
        x = min(x, i[0])
var location = coord2d(x, 1)

# Initially facing right
var facing = coord2d(1, 0)
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
        if newLoc.asTuple in walls:
            break
        location = newLoc

    facing = rot90(facing, step[1].rdir)


var fscr: int
if facing == (1, 0): fscr = 0
if facing == (0, 1): fscr = 1
if facing == (-1, 0): fscr = 2
if facing == (0, -1): fscr = 3

# P1: 181128 correct
echo location.y * 1000 + location.x * 4 + fscr

let cube = """
 12
 3
45
6
"""

# Rotation 90 degrees vector comes from cross product of direction and cube face normal

