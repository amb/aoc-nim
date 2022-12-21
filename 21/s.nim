include ../aoc

let input = "21/input".readFile

let test = """
root: pppw + sjmn
dbpl: 5
cczh: sllz + lgvd
zczc: 2
ptdq: humn - dvpt
dvpt: 3
lfqf: 4
humn: 5
ljgn: 2
sjmn: drzm * dbpl
sllz: 4
pppw: cczh / lfqf
lgvd: ljgn * ptdq
drzm: hmdt - zczc
hmdt: 32"""

type
    Monke = object
        value: int
        a, b: string
        op: proc (a, b: int): int
        giveInfo: seq[string]
        hasGiven: bool

proc parse(input: string): Table[string, Monke] =
    for item in input.splitLines:
        let it = item.split(": ")
        let monkey = it[0]
        let val = it[1]

        if monkey notin result:
            result[monkey] = Monke()
        
        if val[0].isDigit:

            # ASSUMPTION:
            # Input values don't have : 0, so we're ok here
            # if value == 0, it has no value yet
            
            result[monkey].value = val.parseInt
        else:
            let fm = val.split(" ")
            result[monkey].a = fm[0]
            result[monkey].b = fm[2]
            let opt = fm[1]
            if opt == "+": result[monkey].op = (proc (a, b: int): int = a+b)
            elif opt == "-": result[monkey].op = (proc (a, b: int): int = a-b)
            elif opt == "/": result[monkey].op = (proc (a, b: int): int = a div b)
            elif opt == "*": result[monkey].op = (proc (a, b: int): int = a*b)
            else: assert false, "Unknown op"

            if fm[0] notin result: result[fm[0]] = Monke()
            if fm[2] notin result: result[fm[2]] = Monke()
    
            result[fm[0]].giveInfo.add(monkey)
            result[fm[2]].giveInfo.add(monkey)

# var monkeys = parse(test)
var monkeys = parse("21/input".readFile.strip)

# while monkeys[monkeys["root"]].value != monkeys[monkeys["root"]].value:

proc calculate(tryThis: int): int =
    var cloneMonkeys = monkeys.deepCopy
    cloneMonkeys["humn"].value = tryThis
    var sanity = 0
    while cloneMonkeys["root"].value == 0:
        # Apparently the laziness of using 0 as uninitialized bites me back
        inc sanity
        if sanity > 100:
            break
        for k, m in cloneMonkeys.pairs:
            if m.value == 0 and m.op != nil:
                let va = cloneMonkeys[m.a].value
                let vb = cloneMonkeys[m.b].value
                if va != 0 and vb != 0:
                    cloneMonkeys[k].value = m.op(va, vb)
    let mroot = cloneMonkeys["root"]
    return cloneMonkeys[mroot.a].value - cloneMonkeys[mroot.b].value

# Apparently this is called bisection
# https://en.wikipedia.org/wiki/Bisection_method
var step = 100
var curResult = 0
var prevResult = 0
var tryValue = 1000
while true:
    prevResult = curResult
    curResult = calculate(tryValue)
    if curResult == 0:
        echo "result: ", tryValue
        break

    if prevResult.sgn == curResult.sgn:
        step += step div 3 + 1
    elif prevResult.sgn != curResult.sgn:
        step = step div 2

    if curResult < 0:
        tryValue -= step
    elif curResult > 0:
        tryValue += step

# 3379022190351
