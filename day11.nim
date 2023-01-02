include aoc

type
    Operation = object
        value: int
        isSelf: bool
        op: char
    Monkey = ref object
        inspections: int
        items: seq[int]
        divider: int
        targets: array[2, int]
        op: Operation

proc getOrZero(a: seq[int]): int =
    if a.len > 0:
        return a[0]
    else:
        return 0

day 11:
    let monkeysInit = collect:
        for monkeyIn in input.split("\n\n"):
            let mln = monkeyIn.splitLines
            Monkey(
                items: mln[1].ints,
                divider: mln[3].ints[0],
                targets: [mln[4].ints[0], mln[5].ints[0]],
                op: Operation(
                    op: mln[2].split(" ")[^2][0],
                    isSelf: mln[2].ints.len == 0,
                    value: mln[2].ints.getOrZero))
                    
    let commonDivider = monkeysInit.mapIt(it.divider).prod

    proc solve(rounds, divider: int): int = 
        var monkeys = monkeysInit.deepCopy
        for round in 1..rounds:
            for mi in 0..<monkeys.len:
                let mnk = monkeys[mi]
                for i in mnk.items:
                    inc mnk.inspections
                    var worry = i
                    let wval = (if mnk.op.isSelf: worry else: mnk.op.value)
                    if mnk.op.op=='+': worry += wval else: worry *= wval
                    worry = worry div divider
                    let pick = ((worry mod mnk.divider) != 0).int
                    monkeys[mnk.targets[pick]].items.add(worry mod commonDivider)
                mnk.items.setLen(0)
        monkeys.mapIt(it.inspections).sorted[^2..^1].prod

    part 1, 62491: solve(20, 3)
    part 2, 17408399184: solve(10000, 1)
