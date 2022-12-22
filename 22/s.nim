include ../aoc

let data = "22/input".readFile.split("\n\n")

var values: seq[(int, char)]
for r in data[1].findAll(re.re"\d+\w"):
    let tp = (if r[^1].isAlphaAscii: (r[0..^2], r[^1]) else: (r, ' '))
    values.add((tp[0].parseInt, tp[1]))

# X+ = right, Y+ = down
proc rotate(v: (int, int), d: char): (int, int) =
    (if d=='L': (v[1], -v[0]) elif d=='R': (-v[1], v[0]) else: v)

# Initially facing right
var facing = (1, 0)

