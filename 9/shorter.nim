include ../aoc
import std/[options]

type
    Vec2i = object 
        x, y: int

proc vec(x, y: int): Vec2i = Vec2i(x: x, y: y)
proc `*`(a: Vec2i, b: int): Vec2i = Vec2i(x: a.x*b, y: a.y*b)
proc `/`(a: Vec2i, b: Vec2i): Vec2i = Vec2i(x: a.x div b.x, y: a.y div b.y)
proc `/`(a: Vec2i, b: int): Vec2i = Vec2i(x: a.x div b, y: a.y div b)
proc `-`(a, b: Vec2i): Vec2i = Vec2i(x: a.x - b.x, y: a.y - b.y)
proc `+`(a, b: Vec2i): Vec2i = Vec2i(x: a.x + b.x, y: a.y + b.y)
proc `+=`(a: var Vec2i, b: Vec2i) = a = a+b 
proc abs(a: Vec2i): Vec2i = Vec2i(x: abs(a.x), y: abs(a.y))
proc len(a: Vec2i): int = max(abs(a.x), abs(a.y))
proc asTuple(v: Vec2i): (int, int) = (v.x, v.y)

# (0, 0) is left up cause of how arrays are printed
proc moveDir(c: char): Option[Vec2i] =
    case c: 
        of 'L': some(Vec2i(x: -1, y: 0))
        of 'R': some(Vec2i(x: 1, y: 0))
        of 'U': some(Vec2i(x: 0, y: -1))
        of 'D': some(Vec2i(x: 0, y: 1))
        else: none(Vec2i)

proc follow(tail: var Vec2i, head: Vec2i) =
    let disp = head - tail
    if abs(disp.x) > 1 or abs(disp.y) > 1:
        if disp.x * disp.y == 0: tail += disp/len(disp)
        else: tail += disp/abs(disp)

let moves = fil(9).
    mapIt(it.scanTuple("$c $i")).
    filterIt(it[0]).
    mapIt(it[1].moveDir.get * it[2])

var knots = newSeq[Vec2i](10)
var trail1: HashSet[(int, int)]
var trail9: HashSet[(int, int)]
for m in moves:
    let dir = m/len(m)
    for step in 0..<m.len:
        knots[0] += dir
        for kn in 1..9:
            knots[kn].follow(knots[kn-1])
        trail1.incl(knots[1].asTuple)
        trail9.incl(knots[9].asTuple)

echo trail1.len
echo trail9.len