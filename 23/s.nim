include ../aoc

let test = """
.....
..##.
..#..
.....
..##.
....."""

# let data = "23/input".readFile.strip.split("\n")
let data = test.strip.split("\n")

var elfCheck: seq[seq[Coord2D]]
for dirs in @[("NE", "N", "NW"), ("SE", "S", "SW"), ("NW", "W", "SW"), ("NE", "E", "SE")]:
    var il: seq[Coord2D]
    il.add(compass[dirs[0]])
    il.add(compass[dirs[1]])
    il.add(compass[dirs[2]])
    elfCheck.add(il)

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

let boundary = fillBoundary((-1, -1), (width+1, height+1))

for _ in 1..4:
    # Gather suggestions
    var props: Table[Coord2D, Coords2D]
    for elf in elfs:
        let move = elf.proposal(elfs, boundary)
        if move.isSome:
            if move.get notin props:
                props[move.get] = Coords2D()
            props[move.get].incl(elf)

    for elf in elfs:
        let move = elf.proposal(elfs, boundary)
        if move.isSome and move.get in props and props[move.get].len > 1:
            props.del(move.get)

    for move, elf in props.pairs:
        elfs.incl(move)
        elfs.excl(elf)
    
    echo elfs
