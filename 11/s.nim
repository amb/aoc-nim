include ../aoc

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

let monkeys = collect:
    for monkeyIn in readFile("11/input").split("\n\n"):
        let lines = monkeyIn.splitLines
        Monkey(
            items: lines[1].ints,
            divider: lines[3].ints[0],
            targets: [lines[4].ints[0], lines[5].ints[0]],
            op: Operation(
                op: lines[2].split(" ")[^2][0],
                isSelf: lines[2].ints.len == 0,
                value: lines[2].ints.getOrZero(0)))

let commonDivider = monkeys.mapIt(it.divider).prod

for round in 1..10000:
    for mi in 0..<monkeys.len:
        let mnk = monkeys[mi]
        for i in mnk.items:
            inc mnk.inspections
            var worry = i
            let wval = (if mnk.op.isSelf: worry else: mnk.op.value)
            if mnk.op.op=='+': worry += wval else: worry *= wval
            # worry = worry div 3
            let pick = ((worry mod mnk.divider) != 0).int
            monkeys[mnk.targets[pick]].items.add(worry mod commonDivider)
        mnk.items.setLen(0)

echo monkeys.mapIt(it.inspections).sorted[^2..^1].prod