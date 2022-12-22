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
# var tests: seq[string]
for r in data[1].findAll(re.re"\d+\w"):
    let tp = (if r[^1].isAlphaAscii: (r[0..^2], r[^1]) else: (r, ' '))
    movements.add((tp[0].parseInt, tp[1]))
    # tests.add(tp[0] & tp[1])

echo movements.len

# let recon = tests.join
# echo recon[^5..^1]
# echo data[1][^5..^1]
# echo "---"
# for ci, c in recon:
#     if data[1][ci] != recon[ci]:
#         echo ci
#         break

# assert recon.len == data[1].len
# assert recon == data[1]

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

# assert ground.len == 15000
# assert walls.len == 1498

# Solving
var borders: Coords2D
for d in Coords2D.faces:
    borders = borders + ((ground + d) - ground)

echo ground.min, " : ", ground.max
echo borders.min, " : ", borders.max

# Generate path
proc rdir(d: char): int = (if d=='L': -1 elif d=='R': 1 else: 0)

# Find starting position
var x = int.high
for i in ground:
    if i[1] == 1:
        x = min(x, i[0])
var location = vec2i(x, 1)

# Initially facing right
echo "==Moving"
var facing = vec2i(1, 0)
for step in movements:
    for _ in 1..step[0]:
        var newLoc = location + facing
        if newLoc.asTuple in borders:
            while true:
                newLoc -= facing
                if newLoc.asTuple in borders:
                    break
            if (newLoc+facing).asTuple in walls:
                break
            else:
                newLoc += facing
        if newLoc.asTuple in walls:
            break
        location = newLoc
    facing.rotate90(step[1].rdir)
    echo location

var fscr: int
if facing == (1, 0): fscr = 0
if facing == (0, 1): fscr = 1
if facing == (-1, 0): fscr = 2
if facing == (0, -1): fscr = 3
echo location.y * 1000 + location.x * 4 + fscr
echo fmt"{location.x}, {location.y}"

# 180036 too low
# 116172 too low
