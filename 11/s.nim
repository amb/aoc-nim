include ../aoc

type 
    OpType = object
        value: int
        isSelf: bool
        op: char
    Monkey = ref object
        inspections: int
        items: seq[int]
        tests: array[3, int]
        op: OpType

let monkeys = collect:
    for monkeyIn in readFile("11/input").split("\n\n"):
        var newMonkey = Monkey()
        for lc, line in monkeyIn.splitLines().toSeq.pairs:
            let parts = line.split(":")
            if lc == 1: newMonkey.items = collect(for n in parts[1].strip.split(", "): n.parseInt)
            if lc >= 3 and lc <= 5: newMonkey.tests[lc-3] = parts[1].split(" ")[^1].parseInt
            if lc == 2:
                let ip = parts[1].split(" ")[^2..^1]
                newMonkey.op.op = ip[0][0]
                newMonkey.op.isSelf = not intParser(ip[1], newMonkey.op.value)
        newMonkey

# for mnk in monkeys:
#     echo mnk.items
#     echo mnk.tests
#     echo mnk.op.op, " ", mnk.op.value, " ", mnk.op.isSelf

for round in 1..20:
    for mi in 0..<monkeys.len:
        # echo "--- ", mi
        let mnk = monkeys[mi]
        for i in mnk.items:
            inc mnk.inspections
            var worry = 0
            worry += i
            let wval = (if mnk.op.isSelf: worry else: mnk.op.value)
            if mnk.op.op=='+': worry += wval else: worry *= wval
            # echo worry
            worry = worry div 3
            # echo worry
            let pick = int(worry mod mnk.tests[0] != 0)
            monkeys[mnk.tests[pick+1]].items.add(worry)
        mnk.items.setLen(0)

echo monkeys.mapIt(it.inspections).sorted[^2..^1].foldl(a*b)
