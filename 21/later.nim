include ../aoc

type
    Monke = object
        value: Option[int]
        a, b: string
        up: string
        op: proc (a, b: int): int

proc parse(input: string): Table[string, Monke] =
    for item in input.splitLines:
        let it = item.split(": ")
        let monkey = it[0]
        let val = it[1]

        if monkey notin result:
            result[monkey] = Monke()
        
        if val[0].isDigit:
            result[monkey].value = some(val.parseInt)
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

            if fm[0] notin result:
                result[fm[0]] = Monke()
            if fm[2] notin result:
                result[fm[2]] = Monke()

            assert result[fm[0]].up == ""
            assert result[fm[2]].up == ""

            result[fm[0]].up = monkey
            result[fm[2]].up = monkey

var monkeys = parse("21/input".readFile.strip)
var cloneMonkeys = monkeys.deepCopy

# proc tree(): int =
#     for k, v in monkeys:
#         cloneMonkeys[k].value = v.value
#     cloneMonkeys["humn"].value = some(tryThis)
#     while cloneMonkeys["root"].value.isNone:
#         for k, m in cloneMonkeys.pairs:
#             if m.value.isNone and m.op != nil:
#                 let va = cloneMonkeys[m.a].value
#                 let vb = cloneMonkeys[m.b].value
#                 if va.isSome and vb.isSome:
#                     cloneMonkeys[k].value = some(m.op(va.get, vb.get))
#     let mroot = cloneMonkeys["root"]
#     return cloneMonkeys[mroot.a].value.get - cloneMonkeys[mroot.b].value.get

proc calculate(tryThis: int): int =
    for k, v in monkeys:
        cloneMonkeys[k].value = v.value
    cloneMonkeys["humn"].value = some(tryThis)
    while cloneMonkeys["root"].value.isNone:
        for k, m in cloneMonkeys.pairs:
            if m.value.isNone and m.op != nil:
                let va = cloneMonkeys[m.a].value
                let vb = cloneMonkeys[m.b].value
                if va.isSome and vb.isSome:
                    cloneMonkeys[k].value = some(m.op(va.get, vb.get))
    let mroot = cloneMonkeys["root"]
    return cloneMonkeys[mroot.a].value.get - cloneMonkeys[mroot.b].value.get

proc findRootB(fn: proc (v: int): int, maxSteps = int.high): int =
    ## Bisection for integer funtions
    # Apparently this is called bisection
    # ad-hoc implementation, probably could be improved by a lot
    # https://en.wikipedia.org/wiki/Bisection_method
    var step = 10000000
    var curResult = 0
    var prevResult = 0
    var tryValue = 1000
    var curLoop = maxSteps
    while curLoop > 0:
        prevResult = curResult
        curResult = fn(tryValue)
        if curResult == 0:
            return tryValue

        if prevResult.sgn == curResult.sgn:
            step += step div 2 + 1
        elif prevResult.sgn != curResult.sgn:
            step = step div 2
        
        if curResult < 0:
            tryValue -= step
        elif curResult > 0:
            tryValue += step
        dec curLoop

    assert false, "findRoot reached end without finding anything"

let p2 = oneTimeIt:
    findRootB(calculate)

echo p2

# for k, m in monkeys.pairs:
#     echo k, ": ", m