import ../aoc
import ../coords
import std/[sequtils, strutils, strformat, enumerate, tables, sets, math, options]

const testInput = """...#......
.......#..
#.........
..........
......#...
.#........
.........#
..........
.......#..
#...#....."""

day 11:
    let lines = input.splitLines

    # find empty rows
    var emptyRows: HashSet[int]
    for li, l in lines:
        if l.count('#') == 0:
            emptyRows.incl(li)

    # find empty columns
    var emptyCols: HashSet[int]
    for ci in 0..lines[0].high:
        var counter = 0
        for li in 0..lines.high:
            if lines[li][ci] == '#':
                inc counter
        if counter == 0:
            emptyCols.incl(ci)

    # expand rows
    var cursor = 0
    var starMap: seq[string]
    while cursor < lines.len:
        if cursor in emptyRows:
            starMap.add(".".repeat(lines[0].len))
        starMap.add(lines[cursor])
        inc cursor

    # expand columns
    for li, l in starMap:
        var newLine: seq[string]
        for ci in 0..l.high:
            if ci in emptyCols:
                newLine.add(".")
            newLine.add($l[ci])
        starMap[li] = newLine.join("")

    # for l in starMap:
    #     echo l

    let galaxies = starMap.toCoords2D('#').toSeq
    
    var combs2: seq[array[2, int]]
    for i in 0..<galaxies.len:
        for j in 0..i-1:
            combs2.add([i, j])
            
    part 1:
        combs2.mapIt(galaxies[it[0]].manhattan(galaxies[it[1]])).sum

    part 2:
        404
