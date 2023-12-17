import ../aoc
import ../aoc_lib
import std/[sequtils, strutils, strformat, tables, sugar, sets]

let testInput = """RL

AAA = (BBB, CCC)
BBB = (DDD, EEE)
CCC = (ZZZ, GGG)
DDD = (DDD, DDD)
EEE = (EEE, EEE)
GGG = (GGG, GGG)
ZZZ = (ZZZ, ZZZ)"""

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
    echo movements.len

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
            var countZ = 0

            while true:
                let visitId = ghost & $mloc
                if ghost[2] == 'Z':
                    echo "z at: ", steps
                    inc countZ

                if visitId notin visited:
                    visited[visitId] = steps
                else:
                    echo visitId
                    echo "Total steps: ", steps
                    echo "Loop start steps: ", visited[visitId]
                    let ll = steps - visited[visitId]
                    echo "Loop length: ", ll
                    loopLengths.add(ll)
                    doAssert countZ == 1
                    break
                
                ghost = network[ghost][movements[mloc]]
                
                inc mloc
                if mloc == movements.len:
                    mloc = 0

                inc steps
                doAssert steps < 100_000

        doAssert loopLengths.len == ghosts.len

        var speedyGhost: seq[int]
        for i in 0..loopLengths.high:
            speedyGhost.add(loopLengths[i])

        # figure out where the loops match
        # every loop only has one matching location (Z)
        var steps = 0
        while steps < 100_000_000_000_000:
            steps = max(speedyGhost)

            for i in 0..speedyGhost.high:
                if speedyGhost[i] < steps:
                    speedyGhost[i] += loopLengths[i]

            var allMatch = true
            for i in 0..speedyGhost.high:
                if speedyGhost[i] != steps:
                    allMatch = false

            if allMatch:
                echo "All match at: ", steps
                break
        steps
