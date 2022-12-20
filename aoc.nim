# Lots of dumb stuff here

import std/[strutils, strformat, sequtils, sugar, algorithm, math]
import std/[sets, strscans, tables, re, options, monotimes, times]

proc `-`*(a, b: char): int = ord(a) - ord(b)
proc `+`*(a: char, b: int): char = char(ord(a) + b)

proc `*`*(l: seq[int], v: int): seq[int] =
    for i in 0..l.len-1:
        result.add(l[i] * v)
    assert result.len == l.len

proc `*=`*(l: var seq[int], v: int) =
    for i in 0..l.len-1:
        l[i] *= v

# Get and set for seq[seq[T]] with tuple (int, int) indexing
proc `[]`*[T](gd: seq[seq[T]], tp: (int, int)): T = return gd[tp[0]][tp[1]]
proc `[]=`*[T](gd: var seq[seq[T]], tp: (int, int), val: T) = gd[tp[0]][tp[1]] = val
proc `+`*(a, b: (int, int)): (int, int) = (a[0]+b[0], a[1]+b[1])

proc ints*(s: string): seq[int] =
    for r in s.findAll(re"-?\d+"):
        result.add(r.parseInt)

proc getOrZero*(si: seq[int], d: int): int =
    if si.len > 0 and d >= 0 and d < si.len:
        si[d]
    else:
        0

proc rollR[T](a: var seq[T]) =
    let t = a[^1]
    for i in countdown(a.len-1, 1): 
        a[i] = a[i-1]
    a[0] = t

proc rollL[T](a: var seq[T]) =
    let t = a[0]
    for i in countup(0, a.len-2): 
        a[i] = a[i+1]
    a[^1] = t

proc partition*[T](i: seq[T], pss: int): seq[seq[T]] =
    assert i.len mod pss == 0, fmt"Seq len {len(i)} not divisible with {pss}"
    var c: seq[T]
    for v in i:
        c.add(v)
        if c.len == pss:
            result.add(c)
            c.setLen(0)

iterator pieces*[T](s: openArray[T], stopper: openArray[T]): Slice[int] =
    ## Iterating over `s` until last values match `stopper`.
    ## Then continue at the next location to do the same again.
    var sloc = 0
    var loc = 0
    var tloc = 0
    while loc < s.len:
        if stopper[tloc] == s[loc]:
            inc tloc
            # Found ending point
            if tloc == stopper.len:
                yield (sloc..loc-tloc)
                # yield s[sloc..loc-tloc]
                sloc = loc + 1
                tloc = 0
        else:
            tloc = 0
        inc loc
    if sloc <= loc-1:
        yield (sloc..<loc)
        # yield s[sloc..<loc]

proc stringSplit*(s: string, stopper: char): (string, string) =
    var loc = 0
    while loc < s.len:
        if s[loc] == stopper:
            return (s[0..<loc], s[loc+1..s.len-1])
        inc loc
    return (s, "")

proc findIf*[T](s: seq[T], pred: proc(x: T): bool): int =
    result = -1
    for i, x in s:
        if pred(x):
            result = i
            break

iterator findAllIf*[T](s: seq[T], pred: proc(x: T): bool): int =
    for i, x in s:
        if pred(x):
            yield i

iterator slidingWindow*(dt: string, size: int): tuple[index: int, view: string] =
    for i in 0..dt.len-size:
        yield (index: i, view: dt[i..<i+size])

iterator searchSeq*[T](sc: seq[T], dt: seq[T]): int =
    for li in 0..sc.len-dt.len:
        var l2 = 0
        while l2 < dt.len and li+l2 < sc.len and sc[li+l2] == dt[l2]:
            inc l2
        if l2 == dt.len:
            yield li

type
    Vec2i* = object
        x, y: int

proc vec2i*(x, y: int): Vec2i = Vec2i(x: x, y: y)
proc vec2i*(t: (int, int)): Vec2i = Vec2i(x: t[0], y: t[1])
proc vec2i*(t: seq[int]): Vec2i = Vec2i(x: t[0], y: t[1])
proc `*`*(a: Vec2i, b: int): Vec2i = Vec2i(x: a.x*b, y: a.y*b)
proc `/`*(a: Vec2i, b: Vec2i): Vec2i = Vec2i(x: a.x div b.x, y: a.y div b.y)
proc `/`*(a: Vec2i, b: int): Vec2i = Vec2i(x: a.x div b, y: a.y div b)
proc `-`*(a, b: Vec2i): Vec2i = Vec2i(x: a.x - b.x, y: a.y - b.y)
proc `+`*(a, b: Vec2i): Vec2i = Vec2i(x: a.x + b.x, y: a.y + b.y)
proc `+=`*(a: var Vec2i, b: Vec2i) = a = a+b
proc min*(a, b: Vec2i): Vec2i = Vec2i(x: min(a.x, b.x), y: min(a.y, b.y))
proc max*(a, b: Vec2i): Vec2i = Vec2i(x: max(a.x, b.x), y: max(a.y, b.y))
proc abs*(a: Vec2i): Vec2i = Vec2i(x: abs(a.x), y: abs(a.y))
proc sgn*(a: Vec2i): Vec2i = Vec2i(x: sgn(a.x), y: sgn(a.y))
# TODO: len should be maxcoord, manhattan should be len
proc len*(a: Vec2i): int = max(abs(a.x), abs(a.y))
proc manhattan*(a, b: Vec2i): int = abs(a.x-b.x) + abs(a.y-b.y)
proc asTuple*(v: Vec2i): (int, int) = (v.x, v.y)
proc asFloatArray*(v: Vec2i): array[2, float] = [v.x.float, v.y.float]


# Cubism
const CUBEDIRS = [
    (1, 0, 0), (-1, 0, 0),
    (0, 1, 0), (0, -1, 0),
    (0, 0, 1), (0, 0, -1)
]

type CubeCoord = (int, int, int)
type CubeLocs = HashSet[CubeCoord]

proc cubecoord(v: seq[int]): CubeCoord =
    assert v.len == 3
    (v[0], v[1], v[2])

proc cubecoord(x, y, z: int): CubeCoord = (x, y, z)

proc `-`(a, b: CubeCoord): CubeCoord = (a[0]-b[0], a[1]-b[1], a[2]-b[2])
proc `+`(a, b: CubeCoord): CubeCoord = (a[0]+b[0], a[1]+b[1], a[2]+b[2])
proc max(a, b: CubeCoord): CubeCoord = (max(a[0], b[0]), max(a[1], b[1]), max(a[2], b[2]))
proc min(a, b: CubeCoord): CubeCoord = (min(a[0], b[0]), min(a[1], b[1]), min(a[2], b[2]))

proc `+`(cb: CubeLocs, v: CubeCoord): CubeLocs =
    for cube in cb:
        result.incl(cube+v)

proc max(cb: CubeLocs): CubeCoord =
    result = (int.low, int.low, int.low)
    for c in cb:
        result = max(result, c)

proc min(cb: CubeLocs): CubeCoord =
    result = (int.high, int.high, int.high)
    for c in cb:
        result = min(result, c)

proc neighbours(cb: CubeLocs): CubeLocs =
    for cube in cb:
        for loc in CUBEDIRS:
            result.incl(cube+loc)
    result = result - cb

proc allDirections(cb: CubeLocs): seq[CubeCoord] =
    for cube in cb:
        for loc in CUBEDIRS:
            result.add(cube+loc)

proc fillBoundary(cmin, cmax: CubeCoord): CubeLocs =
    for x in cmin[0]..cmax[0]:
        for y in cmin[1]..cmax[1]:
            result.incl(cubecoord(x, y, cmin[2]))
            result.incl(cubecoord(x, y, cmax[2]))
    for x in cmin[0]..cmax[0]:
        for z in cmin[2]..cmax[2]:
            result.incl(cubecoord(x, cmin[1], z))
            result.incl(cubecoord(x, cmax[1], z))
    for y in cmin[1]..cmax[1]:
        for z in cmin[2]..cmax[2]:
            result.incl(cubecoord(cmin[0], y, z))
            result.incl(cubecoord(cmax[0], y, z))

iterator throwNet[T](cubes: CubeLocs, run: proc (ind: CubeLocs): T): T =
    let cmin = cubes.min - (2,2,2)
    let cmax = cubes.max + (2,2,2)
    var outerNodes = fillBoundary(cmin - (1,1,1), cmax + (1,1,1))
    var innerNodes = fillBoundary(cmin, cmax)
    while innerNodes.len > 0:
        let nextStep = (innerNodes.neighbours - outerNodes - cubes)
        outerNodes = innerNodes
        innerNodes = nextStep
        yield run(innerNodes)

proc `-`(ca, cb: CubeLocs): CubeLocs =
    for cube in ca:
        if cube notin cb:
            result.incl(cube)

proc `+`(ca, cb: CubeLocs): CubeLocs =
    for cube in ca:
        result.incl(cube)
    for loc in cb:
        result.incl(loc)

proc `&`(ca, cb: CubeLocs): CubeLocs =
    for loc in cb:
        if loc in ca:
            result.incl(loc)

# Compiling tips:
# nim c -d:danger -d:strip -d:lto -d:useMalloc --mm:arc 10/s.nim

proc prtTime*(t: Duration) =
    let mstime = t.inMicroseconds
    let mlsecs = mstime div 1000
    let mcsecs = mstime - (mlsecs * 1000)
    echo fmt"Time: {mlsecs} ms, {mcsecs} µs"

template oneTimeIt(body: untyped): untyped =
    let timeStart = getMonoTime()
    let val = body
    (getMonoTime() - timeStart).prtTime
    val

# template timeIt*(body: untyped): untyped =
#     var i = 1
#     var (val, d) = oneTimeIt(body)
#     var vals = [val].toSeq
#     while i<3000 and (d*i).inMilliseconds<1000:
#         let (nval, nd) = oneTimeIt(body)
#         if nval != val:
#             vals.add nval
#         d = min(d, nd)
#         inc i
#     (vals[0], d)

type
    Positionals[T] = object
        data: seq[T]
        index: seq[int]
        position: seq[int]

proc `[]`[T](p: Positionals[T], l: int): T = p.data[l]
proc len[T](p: Positionals[T]): int = p.data.len

proc newPositionals[T](d: seq[T]): Positionals[T] =
    result.data = d
    result.index = toSeq(0..d.len-1)
    result.position = toSeq(0..d.len-1)
    assert result.data.len == result.position.len

proc swapItems(p: var Positionals, a, b: int) =
    swap(p.data[a], p.data[b])
    swap(p.index[a], p.index[b])
    swap(p.position[p.index[a]], p.position[p.index[b]])

proc rollRight(p: var Positionals) =
    p.data.rollR
    p.index.rollR
    for i in 0..<p.position.len:
        inc p.position[i]
        if p.position[i] >= p.position.len:
            p.position[i] = 0

proc rollLeft(p: var Positionals) =
    p.data.rollL
    p.index.rollL
    for i in 0..<p.position.len:
        dec p.position[i]
        if p.position[i] < 0:
            p.position[i] = p.position.len-1


