import aoc
import sequtils, strutils, tables, sugar, strscans

day 5:
    # Parse the input into arrays
    # ASSUMPTIONS: 9 crates, grid spacing locations are constant
    let numsLoc = findIf(lines, x => x[1].isDigit)

    var stacks = newSeq[seq[char]](9)
    for l in countdown(numsLoc-1, 0):
        for n in 1..9:
            let ch = lines[l][1 + (n-1)*4]
            if ch.isAlphaAscii:
                stacks[n-1].add(ch)

    let moves = collect:
        for line in lines[numsLoc+1..^1]:
            let (success, count, a, b) = line.scanTuple("move $i from $i to $i")
            if success:
                (count: count, a: a-1, b: b-1)

    # TODO: what are the move semantics here?
    #       Is this deep copy or something else?
    var stacksB = stacks

    part 1, "VCTFTJQCG": 
        for m in moves:
            for i in 0..<m.count:
                stacks[m.b].add(stacks[m.a].pop())

        let t = stacks.mapIt(it[^1])
        t.join

    part 2, "GCFGLDNJZ":
        for m in moves:
            stacksB[m.b] &= stacksB[m.a][^m.count..^1]
            stacksB[m.a].setLen(stacksB[m.a].len - m.count)

        let t = stacksB.mapIt(it[^1])
        t.join