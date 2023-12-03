#region NOTES

# Lots of dumb stuff here

# Compiling tips:
# nim c -d:danger -d:strip -d:lto --mm:orc 10/s.nim
# -d:useMalloc?
# --deepCopy?

# beef @ discord
# --hint[Performance]: on
# type MyObject = object
#   a: string
# proc consume(s: sink MyObject) = discard
# proc doThing() =
#   var a = MyObject(a: "hello world")
#   consume(a)
#   echo a
# doThing()
# ...
# /tmp/test.nim(9, 11) Hint: passing 'a' to a sink parameter introduces an implicit copy; if possible, rearrange your program's control flow to prevent it [Performance]
# Make a config.nims or myproject.nims

# For profiling on Windows11/VerySleepy, this works:
# nim c --debugger:native -d:release --mm:arc day15.nim

# Also could look into https://github.com/wolfpld/tracy
# Integration: https://luxeengine.com/integrating-tracy-profiler-in-cpp/

#endregion

import std/[strutils, strscans, strformat, sequtils, sugar, algorithm, math, os]
import std/[sets, intsets, tables, re, options, monotimes, times, paths, httpclient]

#    _____         _________
#   /  _  \   ____ \_   ___ \
#  /  /_\  \ /  _ \/    \  \/
# /    |    (  <_> )     \____
# \____|__  /\____/ \______  /
#         \/               \/
#region AOC

proc green*(s: string): string = "\e[32m" & s & "\e[0m"
proc grey*(s: string): string = "\e[90m" & s & "\e[0m"
proc yellow*(s: string): string = "\e[33m" & s & "\e[0m"
proc red*(s: string): string = "\e[31m" & s & "\e[0m"

# https://github.com/MichalMarsalek/Advent-of-code/blob/master/2022/Nim/aoc_logic.nim

var SOLUTIONS*: Table[int, proc (x: string): Table[int, string]]

template day*(day: int, solution: untyped): untyped =
    ## Defines a solution function, if isMainModule, runs it.
    block:
        SOLUTIONS[day] = proc (input: string): Table[int, string] =
            var input {.inject, used.} = input.strip(false)
            var parts {.inject.}: OrderedTable[int, proc (): string]
            solution
            for k, v in parts.pairs:
                result[k] = $v()

    if isMainModule:
        run day

template part*(p: int, solution: untyped): untyped =
    ## Defines a part solution function.
    parts[p] = proc (): string =
        proc inner(): auto =
            solution
        return yellow($inner())

template part*(p: int, answer, solution: untyped): untyped =
    ## Defines a part solution function with test for correctness.
    parts[p] = proc (): string =
        proc inner(): auto =
            solution
        let val = inner()
        if val == answer:
            # return green($val)
            return green("✓")
        else:
            return red($val)

proc getInput(day: int): string =
    let filename = fmt"inputs/day{day}.in"
    if fileExists filename:
        return readFile filename
    echo "Input file not found for day " & $day
    quit(QuitFailure)

proc run*(day: int) =
    if day in SOLUTIONS:
        ## Runs given day solution on the corresponding input.
        let dinp = getInput day
        let start = getMonoTime()
        let results = SOLUTIONS[day](dinp)
        let finish = getMonoTime()

        stdout.write "Day " & $day & ":"
        for k in results.keys.toSeq.sorted:
            stdout.write fmt" [P{k}: {results[k]}]"
        let ttime = (finish-start).inMicroseconds
        if ttime < 10000:
            # Under 10 ms
            stdout.write fmt" {green($ttime)} µs"
        elif ttime < 100000:
            # Under 100 ms
            stdout.write fmt" {$ttime} µs"
        elif ttime < 1000000:
            # Under 1 s
            stdout.write fmt" {yellow($ttime)} µs"
        else:
            stdout.write fmt" {red($ttime)} µs"
        echo ""
    else:
        stdout.write "Day " & $day & ": "
        stdout.write yellow("Missing")
        echo ""

#endregion

# _________                                  .__
# \_   ___ \  ____   _______  __ ____   ____ |__| ____   ____   ____  ____
# /    \  \/ /  _ \ /    \  \/ // __ \ /    \|  |/ __ \ /    \_/ ___\/ __ \
# \     \___(  <_> )   |  \   /\  ___/|   |  \  \  ___/|   |  \  \__\  ___/
#  \______  /\____/|___|  /\_/  \___  >___|  /__|\___  >___|  /\___  >___  >
#         \/            \/          \/     \/        \/     \/     \/    \/
# https://patorjk.com/software/taag/#p=display&f=Graffiti
#region CONVENIENCE

proc `-`*(a, b: char): int = ord(a) - ord(b)
proc `+`*(a: char, b: int): char = char(ord(a) + b)

proc `*`*(l: seq[int], v: int): seq[int] =
    for i in 0..l.len-1:
        result.add(l[i] * v)
    assert result.len == l.len

proc `*=`*(l: var seq[int], v: int) =
    for i in 0..l.len-1:
        l[i] *= v

let compassRD* = {"N": (0, -1),
    "S": (0, 1),
    "E": (1, 0),
    "W": (-1, 0),
    "SE": (1, 1),
    "NE": (1, -1),
    "NW": (-1, -1),
    "SW": (-1, 1)}.toTable

#endregion

# __________                     .__
# \______   \_____ _______  _____|__| ____    ____
#  |     ___/\__  \\_  __ \/  ___/  |/    \  / ___\
#  |    |     / __ \|  | \/\___ \|  |   |  \/ /_/  >
#  |____|    (____  /__|  /____  >__|___|  /\___  /
#                 \/           \/        \//_____/
#region PARSING
proc ints*(s: string): seq[int] =
    for r in s.findAll(re"-?\d+"):
        result.add(r.parseInt)

# TODO: notInts

proc dims*(s: seq[string]): (int, int) =
    (s[0].len, s.len)

#endregion

#   _________
#  /   _____/ ____  ________ __   ____   ____   ____  ____   ______
#  \_____  \_/ __ \/ ____/  |  \_/ __ \ /    \_/ ___\/ __ \ /  ___/
#  /        \  ___< <_|  |  |  /\  ___/|   |  \  \__\  ___/ \___ \
# /_______  /\___  >__   |____/  \___  >___|  /\___  >___  >____  >
#         \/     \/   |__|           \/     \/     \/    \/     \/
#region SEQUENCES

proc rollR*[T](a: var seq[T], ps, pe: int) =
    let t = a[pe]
    for i in countdown(pe, ps+1):
        a[i] = a[i-1]
    a[ps] = t

proc rollL*[T](a: var seq[T], ps, pe: int) =
    let t = a[ps]
    for i in countup(ps, pe-1):
        a[i] = a[i+1]
    a[pe] = t

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

proc findIf*[T](s: seq[T], pred: proc(x: T): bool): int =
    result = -1
    for i, x in s:
        if pred(x):
            result = i
            break

iterator slidingWindow*[T](dt: openArray[T], size: int): Slice[int] =
    for i in 0..dt.len-size:
        yield (i..<i+size)

iterator searchSeq*[T](sc: openArray[T], dt: openArray[T]): int =
    for li in 0..sc.len-dt.len:
        var l2 = 0
        while l2 < dt.len and li+l2 < sc.len and sc[li+l2] == dt[l2]:
            inc l2
        if l2 == dt.len:
            yield li

#endregion

# _________                         .___.__               __
# \_   ___ \  ____   ___________  __| _/|__| ____ _____ _/  |_  ____   ______
# /    \  \/ /  _ \ /  _ \_  __ \/ __ | |  |/    \\__  \\   __\/ __ \ /  ___/
# \     \___(  <_> |  <_> )  | \/ /_/ | |  |   |  \/ __ \|  | \  ___/ \___ \
#  \______  /\____/ \____/|__|  \____ | |__|___|  (____  /__|  \___  >____  >
#         \/                         \/         \/     \/          \/     \/
#region COORDINATES

#region 2D

type Coord2D* = (int, int)
type Coords2D* = HashSet[Coord2D]

proc x*(c: Coord2D): int = c[0]
proc y*(c: Coord2D): int = c[1]

proc coord2d*(x, y: int): Coord2D = (x, y)
proc coord2d*(v: seq[int]): Coord2D = (v[0], v[1])
proc coord2d*(t: (int, int)): Coord2D = (t[0], t[1])

proc `*`*(a: Coord2D, b: int): Coord2D = (a[0]*b, a[1]*b)
proc `-`*(a, b: Coord2D): Coord2D = (a[0]-b[0], a[1]-b[1])
proc `+`*(a, b: Coord2D): Coord2D = (a[0]+b[0], a[1]+b[1])
proc `-=`*(a: var Coord2D, b: Coord2D) = a = a-b
proc `+=`*(a: var Coord2D, b: Coord2D) = a = a+b
proc `/`*(a: Coord2D, b: Coord2D): Coord2D = (x: a.x div b.x, y: a.y div b.y)
proc `/`*(a: Coord2D, b: int): Coord2D = (x: a.x div b, y: a.y div b)
proc `==`*(a: var Coord2D, b: (int, int)): bool = a.x == b[0] and a.y == b[1]
proc max*(a, b: Coord2D): Coord2D = (max(a[0], b[0]), max(a[1], b[1]))
proc min*(a, b: Coord2D): Coord2D = (min(a[0], b[0]), min(a[1], b[1]))
proc abs*(a: Coord2D): Coord2D = (x: abs(a.x), y: abs(a.y))
proc sgn*(a: Coord2D): Coord2D = (x: sgn(a.x), y: sgn(a.y))
proc len*(a: Coord2D): int = max(abs(a.x), abs(a.y))
proc manhattan*(a, b: Coord2D): int = abs(a.x-b.x) + abs(a.y-b.y)
proc asTuple*(v: Coord2D): (int, int) = (v.x, v.y)
proc asFloatArray*(v: Coord2D): array[2, float] = [v.x.float, v.y.float]
proc rot90*(v: Coord2D, d: int): Coord2D = (if d == 1 or d == -1: (-v.y*d, v.x*d) else: v)
proc `[]`*(a: Coords2D, i: (int, int)): Coord2D = a[Coord2D(i)]

proc toCoords2D*(data: seq[string], symbol: char): Coords2D =
    for yi, y in data:
        for xi, x in y:
            if x == symbol:
                result.incl((xi, yi))

proc toCoords2D*(data: seq[string], filter: proc (c: char): bool): Coords2D =
    for yi, y in data:
        for xi, x in y:
            if filter(x):
                result.incl((xi, yi))

proc toCoords2D*(data: seq[Coord2D]): Coords2D =
    for i in data:
        result.incl(i)

proc inBounds*(a: Coord2D, w, h: int): bool =
    a[0] >= 0 and a[1] >= 0 and a[0] < w and a[1] < h

proc fill*(T: typedesc[Coords2D], v: int): Coord2D = (v, v)

proc faces*(T: typedesc[Coords2D]): array[4, Coord2D] = [
    (1, 0), (-1, 0),
    (0, 1), (0, -1)]

proc connected*(T: typedesc[Coords2D]): array[8, Coord2D] = [
    (1, 1), (-1, -1),
    (1, -1), (-1, 1),
    (1, 0), (-1, 0),
    (0, 1), (0, -1)]

proc one*(T: typedesc[Coords2D]): Coord2D = (1, 1)
proc zero*(T: typedesc[Coords2D]): Coord2D = (0, 0)

proc fillBoundary*(cmin, cmax: Coord2D): Coords2D =
    for x in cmin[0]..cmax[0]:
        result.incl(coord2d(x, cmin[1]))
        result.incl(coord2d(x, cmax[1]))
    for y in cmin[1]..cmax[1]:
        result.incl(coord2d(cmin[0], y))
        result.incl(coord2d(cmax[0], y))

proc grow*(cds: Coords2D, masked: Coords2D): Coords2D =
    for c in cds:
        result.incl(c)
        for f in Coords2D.connected:
            let loc = c+f
            if loc in masked:
                result.incl(loc)

proc grow*(cds: Coords2D): Coords2D =
    for c in cds:
        result.incl(c)
        for f in Coords2D.connected:
            result.incl(c+f)

proc show*(cds: Coords2D, dims: (int, int), offset = (0, 0)): string =
    var total: seq[string]
    let h = dims[1]
    let w = dims[0]
    for y in 0..h-1:
        var l: seq[char]
        for x in 0..w-1:
            if (x, y) + offset in cds:
                l.add('#')
            else:
                l.add('.')
        total.add(l.join)
    total.join("\n") & "\n"

proc toGrid*(cds: Coords2D, dims: (int, int), offset = (0, 0)): seq[seq[int]] =
    let h = dims[1]
    let w = dims[0]
    for y in 0..h-1:
        var l: seq[int]
        for x in 0..w-1:
            if (x, y) + offset in cds:
                l.add(1)
            else:
                l.add(0)
        result.add(l)

# iterator items*(cb: Coords2D): tuple[coord: Coord2D, index: int] =
#     for i, c in cb.items:
#         yield (coord: c, index: i)

#endregion

#region PACKED
type Packed2D* = int
type Packeds2D* = IntSet

template initPacked2D*(bits: untyped): untyped =
    const PACKEDW = bits
    const PACKEDL = 1 shl PACKEDW

    proc packed2d(x, y: int): Packed2D =
        (y shl PACKEDW) + x

    proc packed2d(v: (int, int)): Packed2D =
        (v[1] shl PACKEDW) + v[0]

    proc coord2d(v: Packed2D): Coord2D =
        let t = v shr PACKEDW
        (v-(t shl PACKEDW), t)

    proc pack(data: Coords2D, offset = (0, 0)): Packeds2D =
        for v in data:
            result.incl((v + offset).packed2d)

    proc pack(data: seq[Coord2D]): Packeds2D =
        for i in data:
            result.incl(packed2d(i))

    proc unpack(pv: Packeds2D): Coords2D =
        for v in pv:
            result.incl(v.coord2d)

    proc unpack(pv: seq[Packed2D]): Coords2D =
        for v in pv:
            result.incl(v.coord2d)

    proc fill(T: typedesc[Packeds2D], v: int): Packed2D = v
    proc faces(T: typedesc[Packeds2D]): array[4, Packed2D] = [1, -1, PACKEDL, -PACKEDL]
    proc one(T: typedesc[Packeds2D]): Packed2D = PACKEDL + 1
    proc zero(T: typedesc[Packeds2D]): Packed2D = 0

#endregion

#region 3D
type Coord3D* = (int, int, int)
type Coords3D* = HashSet[Coord3D]

proc coord3d*(v: seq[int]): Coord3D = (v[0], v[1], v[2])
proc coord3d*(x, y, z: int): Coord3D = (x, y, z)

# def cross(a, b):
#     c = [a[1]*b[2] - a[2]*b[1],
#          a[2]*b[0] - a[0]*b[2],
#          a[0]*b[1] - a[1]*b[0]]

proc `*`*(a: Coord3D, b: int): Coord3D = (a[0]*b, a[1]*b, a[2]*b)
proc `-`*(a, b: Coord3D): Coord3D = (a[0]-b[0], a[1]-b[1], a[2]-b[2])
proc `+`*(a, b: Coord3D): Coord3D = (a[0]+b[0], a[1]+b[1], a[2]+b[2])
proc max*(a, b: Coord3D): Coord3D = (max(a[0], b[0]), max(a[1], b[1]), max(a[2], b[2]))
proc min*(a, b: Coord3D): Coord3D = (min(a[0], b[0]), min(a[1], b[1]), min(a[2], b[2]))

proc fill*(T: typedesc[Coords3D], v: int): Coord3D = (v, v, v)

proc faces*(T: typedesc[Coords3D]): array[6, Coord3D] = [
    (1, 0, 0), (-1, 0, 0),
    (0, 1, 0), (0, -1, 0),
    (0, 0, 1), (0, 0, -1)]

proc one*(T: typedesc[Coords3D]): Coord3D = (1, 1, 1)

proc fillBoundary*(cmin, cmax: Coord3D): Coords3D =
    for x in cmin[0]..cmax[0]:
        for y in cmin[1]..cmax[1]:
            result.incl(coord3d(x, y, cmin[2]))
            result.incl(coord3d(x, y, cmax[2]))
    for x in cmin[0]..cmax[0]:
        for z in cmin[2]..cmax[2]:
            result.incl(coord3d(x, cmin[1], z))
            result.incl(coord3d(x, cmax[1], z))
    for y in cmin[1]..cmax[1]:
        for z in cmin[2]..cmax[2]:
            result.incl(coord3d(cmin[0], y, z))
            result.incl(coord3d(cmax[0], y, z))

#endregion

#region ANY

type AnyCoord* = Coord2D | Coord3D | Packed2D
type AnyCoords* = Coords2D | Coords3D | Packeds2D

proc max*(cb: AnyCoords): AnyCoord =
    result = AnyCoords.fill(int.low)
    for c in cb:
        result = max(result, c)

proc min*(cb: AnyCoords): AnyCoord =
    result = AnyCoords.fill(int.high)
    for c in cb:
        result = min(result, c)

proc `+`*(cb: AnyCoords, v: AnyCoord): AnyCoords =
    for i in cb:
        # TODO: why this excl?
        result.excl(v)
        result.incl(i+v)

proc `-`*(ca, cb: AnyCoords): AnyCoords =
    for cube in ca.items:
        if cube notin cb:
            result.incl(cube)

proc `-=`*(ca: var AnyCoords, cb: AnyCoords) =
    for cube in cb:
        ca.excl(cube)

proc `+`*(ca, cb: AnyCoords): AnyCoords =
    for cube in ca.items:
        result.incl(cube)
    for loc in cb.items:
        result.incl(loc)

proc `&`*(ca, cb: AnyCoords): AnyCoords =
    for loc in cb.items:
        if loc in ca:
            result.incl(loc)

proc neighbours*(cb: AnyCoords): AnyCoords =
    for c in cb:
        for loc in AnyCoords.faces:
            result.incl(c+loc)
    result -= cb

proc allDirections*(cb: AnyCoords): seq[AnyCoords] =
    for c in cb:
        for loc in AnyCoords.faces:
            result.add(c+loc)

iterator throwNet*[AnyCoords, T](cubes: AnyCoords, run: proc (ind: AnyCoords): T): T =
    let drone = AnyCoords.one
    let cmin = cubes.min - drone * 2
    let cmax = cubes.max + drone * 2
    var outerNodes = fillBoundary(cmin - drone, cmax + drone)
    var innerNodes = fillBoundary(cmin, cmax)
    while innerNodes.len > 0:
        let nextStep = (innerNodes.neighbours - outerNodes) - cubes
        outerNodes = innerNodes
        innerNodes = nextStep
        yield run(innerNodes)

#endregion

#endregion

# ___________.__        .__
# \__    ___/|__| _____ |__| ____    ____
#   |    |   |  |/     \|  |/    \  / ___\
#   |    |   |  |  Y Y  \  |   |  \/ /_/  >
#   |____|   |__|__|_|  /__|___|  /\___  /
#                     \/        \//_____/
#region TIMING

proc microTime*(t: Duration): (int, int) =
    let mstime = t.inMicroseconds
    let mlsecs = mstime div 1000
    let mcsecs = mstime - (mlsecs * 1000)
    (mlsecs.int, mcsecs.int)

template oneTimeIt*(body: untyped): untyped =
    let timeStart = getMonoTime()
    let val = body
    block:
        let tvals {.inject.} = (getMonoTime() - timeStart).microTime
        echo fmt"Time: {tvals[0]} ms, {tvals[1]} µs"
    val

#endregion

# .____                         __  .__
# |    |    ____   ____ _____ _/  |_|__| ____   ____     _____   ____   _____   ___________ ___.__.
# |    |   /  _ \_/ ___\\__  \\   __\  |/  _ \ /    \   /     \_/ __ \ /     \ /  _ \_  __ <   |  |
# |    |__(  <_> )  \___ / __ \|  | |  (  <_> )   |  \ |  Y Y  \  ___/|  Y Y  (  <_> )  | \/\___  |
# |_______ \____/ \___  >____  /__| |__|\____/|___|  / |__|_|  /\___  >__|_|  /\____/|__|   / ____|
#         \/          \/     \/                    \/        \/     \/      \/              \/
#region LOCATIONMEMORY

type
    Positionals*[T] = object
        data: seq[T]
        index: seq[int]
        position: seq[int]

proc `[]`*[T](p: Positionals[T], l: int): T = p.data[l]
proc len*[T](p: Positionals[T]): int = p.data.len

proc newPositionals*[T](d: seq[T]): Positionals[T] =
    result.data = d
    result.index = toSeq(0..d.len-1)
    result.position = toSeq(0..d.len-1)
    assert result.data.len == result.position.len

proc swapItems*(p: var Positionals, a, b: int) =
    swap(p.data[a], p.data[b])
    swap(p.index[a], p.index[b])
    swap(p.position[p.index[a]], p.position[p.index[b]])

proc rollRight*(p: var Positionals, ps, pe: int) =
    for i in ps..pe:
        let rpos = p.index[i]
        inc p.position[rpos]
        if p.position[rpos] > pe:
            p.position[rpos] = ps
    p.data.rollR(ps, pe)
    p.index.rollR(ps, pe)

proc rollLeft*(p: var Positionals, ps, pe: int) =
    for i in ps..pe:
        let rpos = p.index[i]
        dec p.position[rpos]
        if p.position[rpos] < ps:
            p.position[rpos] = pe
    p.data.rollL(ps, pe)
    p.index.rollL(ps, pe)

#endregion

# __________
# \______   \ ____   ____  __ _________  ______ ___________  ______
#  |       _// __ \_/ ___\|  |  \_  __ \/  ___// __ \_  __ \/  ___/
#  |    |   \  ___/\  \___|  |  /|  | \/\___ \\  ___/|  | \/\___ \
#  |____|_  /\___  >\___  >____/ |__|  /____  >\___  >__|  /____  >
#         \/     \/     \/                  \/     \/           \/
#region RECURSERS

proc findRoot*(fn: proc (v: int): int, maxSteps = int.high, startVal = 1000): int =
    ## Bisection for integer funtions
    # Apparently this is called bisection
    # ad-hoc implementation, probably could be improved by a lot
    # https://en.wikipedia.org/wiki/Bisection_method
    var step = startVal div 2
    var curResult = 0
    var prevResult = 0
    var tryValue = startVal
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

#endregion

#region RANDOM

type
    IntTable* = object
        data: array[65536, int]
        something: IntSet

proc clear*(t: var IntTable) =
    for i in t.something:
        t.data[i] = 0
    t.something.clear()

proc `[]=`*(t: var IntTable, p: int, val: int) =
    t.something.incl(p)
    t.data[p] = val

proc `in`*(val: int, tb: IntTable): bool = tb.data[val] != 0
proc `notin`*(val: int, tb: IntTable): bool = tb.data[val] == 0

iterator pairs*(t: IntTable): tuple[key: int, val: int] =
    for i in t.something:
        yield (key: i, val: t.data[i])

proc len*(t: IntTable): int = t.something.len


const fops* = toTable {
    "+": proc(x, y: float): float = x + y,
    "-": proc(x, y: float): float = x - y,
    "*": proc(x, y: float): float = x * y,
    "/": proc(x, y: float): float = x / y
}

const iops* = toTable {
    "+": proc(x, y: int): int = x + y,
    "-": proc(x, y: int): int = x - y,
    "*": proc(x, y: int): int = x * y,
    "/": proc(x, y: int): int = x div y
}

proc binarySearch*(f: float -> float, lo = -1e100, hi = 1e100, precision = 1.0): float =
    var lo = lo
    var hi = hi
    while hi - lo > precision:
        result = (lo + hi) / 2.0
        if f(result) < 0.0:
            hi = result
        else:
            lo = result

#endregion


