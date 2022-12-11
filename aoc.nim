import std/[strutils, strformat, sequtils, sugar, algorithm, math, sets, strscans, tables]

proc `-`*(a, b: char): int = ord(a) - ord(b)

# proc filt*(n: int): seq[string] = readFile($n & "/input").splitLines()
proc fil*(n: int): seq[string] = readFile($n & "/input").splitLines()
proc filn*(n: int): seq[string] = fil(n)[0..^2]
proc filr*(n: int): string = readFile($n & "/input")

proc intParser*(s: string, i: var int): bool =
    try:
        i = parseInt(s.strip)
    except ValueError:
        return false
    true

proc partition*[T](i: seq[T], ps: int): seq[seq[T]] =
    doAssert len(i) mod ps == 0, fmt"Seq len {len(i)} not divisible with {ps}"
    var os: seq[seq[T]] = newSeq[seq[T]]()
    var c: seq[T]
    var ci = 0
    for v in i:
        c.add(v)
        ci += 1
        if ci == ps:
            ci = 0
            os.add(c)
            c.setLen(0)
    return os

proc findIf*[T](s: seq[T], pred: proc(x: T): bool): int =
    result = -1
    for i, x in s:
        if pred(x):
            result = i
            break

type
    WindowView* = object
        index: int
        view: string

# TODO: openArray view instead of slice
iterator slidingWindow*(dt: string, size: int): WindowView =
    for i in 0..dt.len-size:
        yield WindowView(index: i, view: dt[i..<i+size])

type
    Vec2i* = object
        x, y: int

proc vec2i*(x, y: int): Vec2i = Vec2i(x: x, y: y)
proc vec2i*(t: (int, int)): Vec2i = Vec2i(x: t[0], y: t[1])
proc `*`*(a: Vec2i, b: int): Vec2i = Vec2i(x: a.x*b, y: a.y*b)
proc `/`*(a: Vec2i, b: Vec2i): Vec2i = Vec2i(x: a.x div b.x, y: a.y div b.y)
proc `/`*(a: Vec2i, b: int): Vec2i = Vec2i(x: a.x div b, y: a.y div b)
proc `-`*(a, b: Vec2i): Vec2i = Vec2i(x: a.x - b.x, y: a.y - b.y)
proc `+`*(a, b: Vec2i): Vec2i = Vec2i(x: a.x + b.x, y: a.y + b.y)
proc `+=`*(a: var Vec2i, b: Vec2i) = a = a+b
proc abs*(a: Vec2i): Vec2i = Vec2i(x: abs(a.x), y: abs(a.y))
proc sgn*(a: Vec2i): Vec2i = Vec2i(x: sgn(a.x), y: sgn(a.y))
proc len*(a: Vec2i): int = max(abs(a.x), abs(a.y))
proc asTuple*(v: Vec2i): (int, int) = (v.x, v.y)

# Compiling tips:
# nim c -d:danger -d:strip -d:lto -d:useMalloc --mm:arc 10/s.nim 
