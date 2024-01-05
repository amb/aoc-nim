import ../aoc
import ../aoc_lib
import std/[sequtils, strutils, strformat, enumerate, tables, sets, math, options, streams]

day 14:
    proc `$`[char](grid: Grid2D[char]): string =
        return grid.data.join("")

    proc countSupport(grid: Grid2D[char]): int =
        for y in 0..<grid.height:
            for x in 0..<grid.width:
                if grid[x, y] == 'O':
                    result += grid.height - y

    proc eekOut(grid: var Grid2D[char]) =
        for y in 0..<grid.height:
            var counter = 0
            var start = 0
            for x in 0..<grid.width:
                if grid[x, y] == 'O':
                    inc counter
                if grid[x, y] == '#':
                    for i in start..<start + counter:
                        grid[i, y] = 'O'
                    for i in start + counter..<x:
                        grid[i, y] = '.'
                    start = x + 1
                    counter = 0
            for i in start..<start + counter:
                grid[i, y] = 'O'
            for i in start + counter..<grid.width:
                grid[i, y] = '.'

    part 1, 109596:
        var grid = input.toGrid2D
        grid.rotCCW
        grid.eekOut
        grid.rotCW
        countSupport(grid)

    part 2, 96105:
        var grid = input.toGrid2D
        var prevCycles: Table[string, int]
        grid.rotCCW

        var scratch = grid

        proc oneCycle() =
            for _ in 0..<2:
                grid.eekOut
                grid.rotCW(scratch)
                scratch.eekOut
                scratch.rotCW(grid)

        var remaining = 0
        for i in 0..<100_000:
            let tgrid = $grid
            if tgrid in prevCycles:
                let prev = prevCycles[tgrid]
                echo "Found cycle at ", i, " (", prev, ")"
                remaining = (1_000_000_000 - prev).floorMod(i - prev)
                break
            else:
                prevCycles[tgrid] = i
            oneCycle()

        for i in 0..<remaining:
            oneCycle()

        grid.rotCW
        countSupport(grid)
