include ../aoc

let test = """
..............
..............
.......#......
.....###.#....
...#...#.#....
....#...##....
...#.###......
...##.#.##....
....#..#......
..............
..............
.............."""

let data = "23/input".readFile.strip.split("\n")
# let data = test.strip.split("\n")

var elfCheck: seq[seq[Coord2D]]
for dirs in @[("NE", "N", "NW"), ("SE", "S", "SW"), ("NW", "W", "SW"), ("NE", "E", "SE")]:
    var il: seq[Coord2D]
    il.add(compass[dirs[0]])
    il.add(compass[dirs[1]])
    il.add(compass[dirs[2]])
    elfCheck.add(il)

let surround = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"].mapIt(compass[it]).toCoords2D

proc proposal(elf: Coord2D, tiles, bounds: Coords2D): Option[Coord2D] =
    for dirs in elfCheck:
        var hasPos = true
        for direction in dirs:
            let newPos = elf+direction
            if newPos in tiles or newPos in bounds:
                hasPos = false
        if hasPos:
            return some(elf+dirs[1])
    return none(Coord2D)

var elfs = data.toCoords2D('#')

let width = data[0].len
let height = data.len
echo data[0][^5..^1]
echo data[^1]
echo fmt"w:{width} h:{height}"
# var boundary = fillBoundary((-1, -1), (width, height))
var boundary = Coords2D()

let display = false

# for r in 1..10:
var r = 0
while true:
    inc r
    if display:
        echo fmt"== Round: {r}"

    # Gather suggestions
    var props: Table[Coord2D, Coords2D]
    for elf in elfs:
        if surround.mapIt(int((elf+it) in elfs)).sum > 0:
            let move = elf.proposal(elfs, boundary)
            if move.isSome:
                if move.get notin props:
                    props[move.get] = Coords2D()
                props[move.get].incl(elf)

    if props.len == 0:
        break

    for elf in elfs:
        let move = elf.proposal(elfs, boundary)
        if move.isSome and move.get in props and props[move.get].len > 1:
            props.del(move.get)

    for move, elf in props.pairs:
        elfs.excl(elf)
        elfs.incl(move)
    
    if display:
        echo elfs.show((width, height))

    elfCheck.rollL(0, elfCheck.high)

let box = elfs.max-elfs.min+(1,1)
echo box[0] * box[1] - elfs.len

echo r

# p1 2526 too low, 4045 right

