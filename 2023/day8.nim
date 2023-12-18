import ../aoc
import std/[sequtils, strutils, tables, math]

type MoveChoice = object
    left: string
    right: string

proc `[]`(mc: MoveChoice, i: int): string =
    if i == 0:
        result = mc.left
    else:
        result = mc.right

day 8:
    let lines = input.splitLines
    let movements = lines[0].mapIt(if it == 'L': 0 else: 1)
    let network = lines[2..^1].mapIt((it[0..2], MoveChoice(left: it[7..9], right: it[12..14]))).toTable

    part 1, 12599:
        var location = "AAA"
        var mloc = 0
        var steps = 0
        while location != "ZZZ":
            location = network[location][movements[mloc]]
            # echo location
            inc mloc
            if mloc == movements.len:
                mloc = 0
            inc steps
            assert steps < 100_000_000
        steps

    part 2, 8245452805243:
        var ghosts: seq[string]
        for k, v in network:
            if k[2] == 'A':
                ghosts.add(k)

        var loopLengths: seq[int]
        for gi in 0..ghosts.high:
            # find ghost repetition interval
            var mloc = 0
            var steps = 0
            var ghost = ghosts[gi]
            var visited: Table[string, int]
            while true:
                let visitId = ghost & $mloc
                if visitId notin visited:
                    visited[visitId] = steps
                else:
                    loopLengths.add(steps - visited[visitId])
                    break
                
                ghost = network[ghost][movements[mloc]]
                
                inc mloc
                if mloc == movements.len:
                    mloc = 0

                inc steps
                doAssert steps < 100_000

        # figure out where the loops match
        var common = loopLengths[0]
        for i in 1..loopLengths.high:
            common = lcm(common, loopLengths[i])
        common
