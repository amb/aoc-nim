import strutils, sequtils, tables
include ../aoc

type Rational = object
    n: int64
    d: int64

type Op = object
    a:string
    op:char
    b:string

proc simplify(num:Rational): Rational =
    var a = num.n
    var b = num.d
    if b<0:
        a = -a
        b = -b
    var i: int64 = 1
    let babs = b.abs
    while i<babs:
        inc i
        if ((a mod i) == 0) and ((b mod i) == 0):
            a = a div i
            b = b div i
            i=1
    return Rational(n: a, d: b)

proc parseRational(s:string) : Rational = 
    return Rational(n:s.parseInt, d: 1)
proc `-`(a: Rational):Rational = 
    return simplify(Rational(n: -a.n, d: a.d))

proc `+`(a,b: Rational):Rational = 
    result = simplify(Rational(n:a.n*b.d+a.d*b.n, d:a.d*b.d))

proc `-`(a,b: Rational):Rational = 
    return a + (-b)

proc `*`(ra,rb: Rational):Rational = 
    let a = simplify(ra)
    let b = simplify(rb)
    let q = simplify(Rational(n:a.n, d:b.d))
    let p = simplify(Rational(n:b.n, d:a.d))
    return simplify(Rational(n:q.n*p.n, d:q.d*p.d))

proc `/`(a,b: Rational):Rational = 
    return a*Rational(n:b.d, d:b.n)

proc parseInput(data: string): (Table[string, Rational], Table[string, Op]) =
    var known = initTable[string, Rational]()
    var ops = initTable[string, Op]()
    let file = data.splitLines

    for l in file:
        let data = l.split({' ', ':'}).filterIt(it.len>0)

        if data.len == 2:
            known[data[0]] = parseRational(data[1])
        elif data.len == 4:
            ops[data[0]] = Op(a:data[1], op: data[2][0], b:data[3])
        else:
            quit "unreachable"
    return (known, ops)

proc dfs(find: string, known: Table[string, Rational], ops: Table[string, Op]) : Rational = 
    if known.hasKey find:
        return known[find]
    if not ops.hasKey find:
        quit "unreachable 2"

    let op = ops[find]
    if op.op == '+':
        result = dfs(op.a,known, ops) + dfs(op.b,known, ops)
    elif op.op == '-':
        result = dfs(op.a,known, ops) - dfs(op.b,known, ops)
    elif op.op == '*':
        result = dfs(op.a,known, ops) * dfs(op.b,known, ops)
    elif op.op == '/':
        result = dfs(op.a,known, ops) / dfs(op.b,known, ops)
    else:
        quit "unreachable 3"


proc fn(i: Rational, fixedKnown: Table[string, Rational], ops: Table[string, Op]) : Rational = 
    var known = fixedKnown
    known["humn"] = i
    let op = ops["root"]
    return dfs(op.a, known, ops)-dfs(op.b, known, ops)

proc solve(): (int64, int64) = 
    let (known, ops) = parseInput("21/input".readFile.strip)
    let p1 = dfs("root", known, ops).n
    let z = parseRational("0")
    let o = parseRational("1")
    let on = parseRational("-1")
    let fz = fn(z, known, ops)
    let sol1 = (fz/(fn(on, known, ops)-fz))
    let sol2 = z-(fz/(fn(o, known, ops)-fz))
    let p2 = sol1.n
    doAssert sol1 == sol2
    return (p1,p2)

let (p1,p2) = oneTimeIt:
    let s = solve()
    (s[0], s[1])
echo "P1: ", p1
echo "P2: ", p2


