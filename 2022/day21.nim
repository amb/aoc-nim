import ../aoc
import strutils, tables, options

day 21:
    type
        Monke = object
            value: Option[int]
            a, b: string
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
                result[monkey].op = iops[fm[1]]

    let monkeys = parse(input)
    var cloneMonkeys = monkeys.deepCopy

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

    part 1, 223971851179174:
        discard calculate(monkeys["humn"].value.get)
        cloneMonkeys["root"].value.get

    part 2, 3379022190351: findRoot(calculate)
