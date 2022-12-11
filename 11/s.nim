include ../aoc

type
    OpType = object
        value: int
        isSelf: bool
        op: char
    Monkey = ref object
        inspections: int
        items: seq[int]
        divider: int
        targets: array[2, int]
        op: OpType

let monkeys = collect:
    for monkeyIn in readFile("11/input").split("\n\n"):
        var newMonkey = Monkey()
        for lc, line in monkeyIn.splitLines().toSeq.pairs:
            let parts = line.split(":")
            if lc == 1:
                newMonkey.items = collect:
                    for n in parts[1].strip.split(", "):
                        n.parseInt
            if lc == 2:
                let ip = parts[1].split(" ")[^2..^1]
                newMonkey.op.op = ip[0][0]
                newMonkey.op.isSelf = not intParser(ip[1], newMonkey.op.value)
            if lc == 3:
                newMonkey.divider = parts[1].split(" ")[^1].parseInt
            if lc == 4 or lc == 5:
                newMonkey.targets[lc-4] = parts[1].split(" ")[^1].parseInt
        newMonkey

let commonDivider = monkeys.mapIt(it.divider).foldl(a*b)

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

    if round in [20, 1000, 5000, 10000]:
        echo "Round: ", round
        for mnk in monkeys:
            echo mnk.inspections

echo monkeys.mapIt(it.inspections).sorted[^2..^1].foldl(a*b)
