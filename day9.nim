include ../aoc
import std/[options]

type
    Vec2D = object 
        x, y: int
    BoundingBox2D = object
        left, right, top, bottom: int

proc vec(x, y: int): Vec2D = Vec2D(x: x, y: y)
proc `*`(a: Vec2D, b: int): Vec2D = Vec2D(x: a.x*b, y: a.y*b)
proc `/`(a: Vec2D, b: Vec2D): Vec2D = Vec2D(x: a.x div b.x, y: a.y div b.y)
proc `/`(a: Vec2D, b: int): Vec2D = Vec2D(x: a.x div b, y: a.y div b)
proc `-`(a, b: Vec2D): Vec2D = Vec2D(x: a.x - b.x, y: a.y - b.y)
proc `+`(a, b: Vec2D): Vec2D = Vec2D(x: a.x + b.x, y: a.y + b.y)
proc `+=`(a: var Vec2D, b: Vec2D) = a = a+b 
proc abs(a: Vec2D): Vec2D = Vec2D(x: abs(a.x), y: abs(a.y))
proc len(a: Vec2D): int = max(abs(a.x), abs(a.y))
proc asTuple(v: Vec2D): (int, int) = (v.x, v.y)
proc touching(a, b: Vec2D): bool =
    let adisp = (a-b).abs
    adisp.x <= 1 and adisp.y <= 1

# (0, 0) is left up cause of how arrays are printed
proc moveDir(c: char): Option[Vec2D] =
    case c: 
        of 'L': some(Vec2D(x: -1, y: 0))
        of 'R': some(Vec2D(x: 1, y: 0))
        of 'U': some(Vec2D(x: 0, y: -1))
        of 'D': some(Vec2D(x: 0, y: 1))
        else: none(Vec2D)

proc expand(bb: var BoundingBox2D, loc: Vec2D) =
    bb.left = min(bb.left, loc.x)
    bb.right = max(bb.right, loc.x)
    bb.top = min(bb.top, loc.x)
    bb.bottom = max(bb.bottom, loc.x)

proc size(bb: BoundingBox2D): Vec2D =
    return Vec2D(x: bb.right - bb.left + 1, y: bb.bottom - bb.top + 1)

proc follow(tail: var Vec2D, head: Vec2D) =
    let disp = head - tail
    if tail.touching(head): return
    if disp == vec(-2, 0): tail += vec(-1, 0)
    elif disp == vec(2, 0): tail += vec(1, 0)
    elif disp == vec(0, -2): tail += vec(0, -1)
    elif disp == vec(0, 2): tail += vec(0, 1)
    else: tail += disp/abs(disp)

let moves = "9/input".readFile.splitLines.
    mapIt(it.scanTuple("$c $i")).
    filterIt(it[0]).
    mapIt(it[1].moveDir.get * it[2])

var bb: BoundingBox2D
for m in moves:
    bb.expand(m)
echo "Movement area size: ", bb.size

var knots = newSeq[Vec2D](10)
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