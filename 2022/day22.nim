import ../aoc
import sequtils, strutils, tables, sets, re

type Grid[T] = seq[seq[T]]

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

day 22:
    const SIDES = [(1, 0), (0, 1), (-1, 0), (0, -1)]
    type Side = enum right, bottom, left, top

    # Parsing
    let data = input.split("\n\n")

    var movements: seq[(int, char)]
    for r in data[1].findAll(re.re"\d+\w"):
        let tp = (if r[^1].isAlphaAscii: (r[0..^2], r[^1]) else: (r, ' '))
        movements.add((tp[0].parseInt, tp[1]))

    let glns = data[0].splitLines
    var walls = glns.toCoords2D('#') + (1, 1)
    var ground = (glns.toCoords2D('.') + (1, 1)) + walls

    let zgrid = (ground.max - ground.min + (1, 1)) / 50
    # var zones: Grid[Grid[int]]

    proc locToGrid(l: Coord2D): Coord2D = (l - (1, 1)) / 50

    # TODO: grid transitions
    # [(from, to), (grid_loc, side, flipped)]
    var transition: Table[(Coord2D, Coord2D), (Coord2D, Side, bool)]

    let cube = """
     12
     3
    45
    6
    """

    transition[((2, 0), (3, 0))] = ((1, 0), Side.left, false)
    transition[((1, 0), (0, 0))] = ((2, 0), Side.right, false)

    transition[((1, 1), (2, 1))] = ((1, 1), Side.left, false)
    transition[((1, 1), (0, 1))] = ((1, 1), Side.right, false)

    transition[((1, 2), (2, 2))] = ((0, 2), Side.left, false)
    transition[((0, 2), (-1, 2))] = ((1, 2), Side.right, false)

    # Initially facing right
    var facing = coord2d(1, 0)
    var loc = coord2d((ground.toSeq.filterIt(it[1] == 1).min)[0], 1)
    var borders = ground.neighbours
    for step in movements:
        for _ in 1..step[0]:
            var newLoc = loc + facing
            if newLoc.asTuple in borders:
                # Transition to another region
                while true:
                    newLoc -= facing
                    if newLoc.asTuple in borders:
                        break
                newLoc += facing
            if newLoc.asTuple in walls:
                break
            loc = newLoc

        facing = rot90(facing, int(step[1] == 'R') - int(step[1] == 'L'))

    part 1, 181128: loc.y * 1000 + loc.x * 4 + SIDES.find(facing)

    # Rotation 90 degrees vector comes from cross product of direction and cube face normal

