import ../aoc
import std/[sequtils, strutils, strformat, enumerate, tables, sets, math, options]

const testInput = """#.##..##.
..#.##.#.
##......#
##......#
..#.##.#.
..##..##.
#.#.##.#.

#...##..#
#....#..#
..##..###
#####.##.
#####.##.
..##..###
#....#..#"""

day 13:
    let mazes = input.split("\n\n")

    proc findMirror(s: seq[string]): int =
        for li in 1..s.high:
            if s[li-1] == s[li]:
                result = li
                var match = true
                for j in 1..li-1:
                    # a: li-1-j
                    # b: li+j
                    if li+j > s.high:
                        break
                    if s[li-1-j] != s[li+j]:
                        match = false
                        result = 0
                if match:
                    break

    var total_rows = 0
    var total_cols = 0
    for mi in 0..mazes.high:
        let maze = mazes[mi].splitLines

        total_rows += maze.findMirror

        # transpose maze
        var maze_t: seq[string]
        for j in 0..maze[0].high:
            maze_t.add(maze.mapIt(it[j]).join)

        total_cols += maze_t.findMirror

    part 1, 37561:
        total_cols + total_rows * 100

    part 2:
        404

