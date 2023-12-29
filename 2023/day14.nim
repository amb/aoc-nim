import ../aoc
import std/[sequtils, strutils, strformat, enumerate, tables, sets, math, options, streams]

type Grid2D*[T] = object
    data: seq[T]
    width, height: int

proc newGrid2D*[T](width, height: int): Grid2D[T] =
    Grid2D[T](data: newSeq[T](width * height), width: width, height: height)

proc `[]`*[T](grid: Grid2D[T], x, y: int): T =
    grid.data[y * grid.width + x]

proc `[]=`*[T](grid: var Grid2D[T], x, y: int, value: T) =
    grid.data[y * grid.width + x] = value

proc newGrid2DfromText*(text: string): Grid2D[char] =
    let lines = text.splitLines
    let width = lines[0].len
    let height = lines.len
    assert lines[height - 1].len == width

    var grid = newGrid2D[char](width, height)
    for y, line in lines:
        for x in 0..<line.len:
            grid[x, y] = line[x]
    return grid

proc printGrid2D*[T](grid: Grid2D[T]) =
    for y in 0..<grid.height:
        for x in 0..<grid.width:
            stdout.write(grid[x, y])
        echo ""

proc `$`[char](grid: Grid2D[char]): string =
    return grid.data.join("")

const testInput = """O....#....
O.OO#....#
.....##...
OO.#O....O
.O.....O#.
O.#..O.#.#
..O..#O..O
.......O..
#....###..
#OO..#...."""

day 14:
    # let lines = testInput.splitLines
    # grid.printGrid2D

    proc rollGrid(grid: var Grid2D[char], xd, yd: int): bool =
        # result = if any of the rocks moved
        for y in 0..<grid.height:
            if y + yd < 0 or y + yd >= grid.height:
                continue
            for x in 0..<grid.width:
                if not (x + xd < 0 or x + xd >= grid.width) and grid[x, y] == 'O':
                    if grid[x + xd, y + yd] == '.':
                        grid[x + xd, y + yd] = 'O'
                        grid[x, y] = '.'
                        result = true

    proc countSupport(grid: Grid2D[char]): int =
        var total = 0
        for y in 0..<grid.height:
            for x in 0..<grid.width:
                if grid[x, y] == 'O':
                    total += grid.height - y
        total

    part 1, 109596:
        var grid = newGrid2DfromText(input)

        while rollGrid(grid, 0, -1):
            discard

        countSupport(grid)

    part 2, 96105:
        var grid = newGrid2DfromText(input)
        var prevCycles: Table[string, int]

        proc oneCycle() =
            while rollGrid(grid, 0, -1): discard
            while rollGrid(grid, -1, 0): discard
            while rollGrid(grid, 0, 1): discard
            while rollGrid(grid, 1, 0): discard

        var remaining = 0
        for i in 0..<100_000:
            if i > 0 and $grid in prevCycles:
                echo "cycle found at ", i
                let prev = prevCycles[$grid]
                echo "connection: ", prev
                remaining = (1_000_000_000 - prev).floorMod(i - prev)
                echo "remainder: ", remaining
                break
            else:
                prevCycles[$grid] = i
            # if i < 4:
            #     echo "After ", i, " cycles:"
            #     grid.printGrid2D
            #     echo ""
            oneCycle()

        for i in 0..<remaining:
            oneCycle()

        countSupport(grid)
