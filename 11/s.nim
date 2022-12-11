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
        var nmnk = Monkey()
        let lines = monkeyIn.splitLines().mapIt(it.split(":")[1])
        nmnk.items = lines[1].parseInts
        let ip = lines[2].split(" ")[^2..^1]
        nmnk.op.op = ip[0][0]
        nmnk.op.isSelf = not intParser(ip[1], nmnk.op.value)
        nmnk.divider = lines[3].parseInts[0]
        for i in 0..1:
            nmnk.targets[i] = lines[4+i].parseInts[0]
        nmnk

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