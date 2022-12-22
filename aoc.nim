# Lots of dumb stuff here
# Compiling tips:
# nim c -d:danger -d:strip -d:lto -d:useMalloc --mm:arc 10/s.nim

import std/[strutils, strformat, sequtils, sugar, algorithm, math]
import std/[sets, strscans, tables, re, options, monotimes, times]

# _________                                  .__                            
# \_   ___ \  ____   _______  __ ____   ____ |__| ____   ____   ____  ____  
# /    \  \/ /  _ \ /    \  \/ // __ \ /    \|  |/ __ \ /    \_/ ___\/ __ \ 
# \     \___(  <_> )   |  \   /\  ___/|   |  \  \  ___/|   |  \  \__\  ___/ 
#  \______  /\____/|___|  /\_/  \___  >___|  /__|\___  >___|  /\___  >___  >
#         \/            \/          \/     \/        \/     \/     \/    \/ 
# https://patorjk.com/software/taag/#p=display&f=Graffiti

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
# TODO: [y][x] instead of [x][y]
proc `[]`*[T](gd: seq[seq[T]], tp: (int, int)): T = return gd[tp[0]][tp[1]]
proc `[]=`*[T](gd: var seq[seq[T]], tp: (int, int), val: T) = gd[tp[0]][tp[1]] = val

# __________                     .__                
# \______   \_____ _______  _____|__| ____    ____  
#  |     ___/\__  \\_  __ \/  ___/  |/    \  / ___\ 
#  |    |     / __ \|  | \/\___ \|  |   |  \/ /_/  >
#  |____|    (____  /__|  /____  >__|___|  /\___  / 
#                 \/           \/        \//_____/  

proc ints*(s: string): seq[int] =
    for r in s.findAll(re"-?\d+"):
        result.add(r.parseInt)

# TODO: notInts

#   _________                                                      
#  /   _____/ ____  ________ __   ____   ____   ____  ____   ______
#  \_____  \_/ __ \/ ____/  |  \_/ __ \ /    \_/ ___\/ __ \ /  ___/
#  /        \  ___< <_|  |  |  /\  ___/|   |  \  \__\  ___/ \___ \ 
# /_______  /\___  >__   |____/  \___  >___|  /\___  >___  >____  >
#         \/     \/   |__|           \/     \/     \/    \/     \/ 

proc rollR[T](a: var seq[T], ps, pe: int) =
    let t = a[pe]
    for i in countdown(pe, ps+1): 
        a[i] = a[i-1]
    a[ps] = t

proc rollL[T](a: var seq[T], ps, pe: int) =
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

# TODO: openarray
iterator searchSeq*[T](sc: seq[T], dt: seq[T]): int =
    for li in 0..sc.len-dt.len:
        var l2 = 0
        while l2 < dt.len and li+l2 < sc.len and sc[li+l2] == dt[l2]:
            inc l2
        if l2 == dt.len:
            yield li

# .___        __                         __                       
# |   | _____/  |_  ___  __ ____   _____/  |_  ___________  ______
# |   |/    \   __\ \  \/ // __ \_/ ___\   __\/  _ \_  __ \/  ___/
# |   |   |  \  |    \   /\  ___/\  \___|  | (  <_> )  | \/\___ \ 
# |___|___|  /__|     \_/  \___  >\___  >__|  \____/|__|  /____  >
#          \/                  \/     \/                       \/ 

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
proc `-=`*(a: var Vec2i, b: Vec2i) = a = a-b
proc `+`*(a, b: Vec2i): Vec2i = Vec2i(x: a.x + b.x, y: a.y + b.y)
proc `+=`*(a: var Vec2i, b: Vec2i) = a = a+b
proc `==`*(a: var Vec2i, b: (int, int)): bool = a.x == b[0] and a.y == b[1]
proc min*(a, b: Vec2i): Vec2i = Vec2i(x: min(a.x, b.x), y: min(a.y, b.y))
proc max*(a, b: Vec2i): Vec2i = Vec2i(x: max(a.x, b.x), y: max(a.y, b.y))
proc abs*(a: Vec2i): Vec2i = Vec2i(x: abs(a.x), y: abs(a.y))
proc sgn*(a: Vec2i): Vec2i = Vec2i(x: sgn(a.x), y: sgn(a.y))
# TODO: len should be maxcoord, manhattan should be len
proc len*(a: Vec2i): int = max(abs(a.x), abs(a.y))
proc manhattan*(a, b: Vec2i): int = abs(a.x-b.x) + abs(a.y-b.y)
proc asTuple*(v: Vec2i): (int, int) = (v.x, v.y)
proc asFloatArray*(v: Vec2i): array[2, float] = [v.x.float, v.y.float]
proc rotate90*(v: var Vec2i, d: int) = 
    if d != -1 and d != 1:
        return
    let t = v.x
    v.x = -v.y * d
    v.y = t * d

# _________                         .___             __          
# \_   ___ \  ____   ___________  __| _/______ _____/  |_  ______
# /    \  \/ /  _ \ /  _ \_  __ \/ __ |/  ___// __ \   __\/  ___/
# \     \___(  <_> |  <_> )  | \/ /_/ |\___ \\  ___/|  |  \___ \ 
#  \______  /\____/ \____/|__|  \____ /____  >\___  >__| /____  >
#         \/                         \/    \/     \/          \/ 

type Coord2D = (int, int)
type Coords2D = HashSet[Coord2D]

type Coord3D = (int, int, int)
type Coords3D = HashSet[Coord3D]

type AnyCoord = Coord2D | Coord3D
type AnyCoords = Coords2D | Coords3D

proc coord2d(v: seq[int]): Coord2D = (v[0], v[1])
proc coord3d(v: seq[int]): Coord3D = (v[0], v[1], v[2])

proc coord2d(x, y: int): Coord2D = (x, y)
proc coord3d(x, y, z: int): Coord3D = (x, y, z)

proc `*`(a: Coord3D, b: int): Coord3D = (a[0]*b, a[1]*b, a[2]*b)
proc `-`(a, b: Coord3D): Coord3D = (a[0]-b[0], a[1]-b[1], a[2]-b[2])
proc `+`(a, b: Coord3D): Coord3D = (a[0]+b[0], a[1]+b[1], a[2]+b[2])
proc max(a, b: Coord3D): Coord3D = (max(a[0], b[0]), max(a[1], b[1]), max(a[2], b[2]))
proc min(a, b: Coord3D): Coord3D = (min(a[0], b[0]), min(a[1], b[1]), min(a[2], b[2]))

proc `*`(a: Coord2D, b: int): Coord2D = (a[0]*b, a[1]*b)
proc `-`(a, b: Coord2D): Coord2D = (a[0]-b[0], a[1]-b[1])
proc `+`(a, b: Coord2D): Coord2D = (a[0]+b[0], a[1]+b[1])
proc max(a, b: Coord2D): Coord2D = (max(a[0], b[0]), max(a[1], b[1]))
proc min(a, b: Coord2D): Coord2D = (min(a[0], b[0]), min(a[1], b[1]))

proc fill(T: typedesc[Coords2D], v: int): Coord2D = (v, v)
proc fill(T: typedesc[Coords3D], v: int): Coord3D = (v, v, v)

proc faces(T: typedesc[Coords2D]): array[4, Coord2D] = [
    (1, 0), (-1, 0),
    (0, 1), (0, -1)]

proc faces(T: typedesc[Coords3D]): array[6, Coord3D] = [
    (1, 0, 0), (-1, 0, 0),
    (0, 1, 0), (0, -1, 0),
    (0, 0, 1), (0, 0, -1)]

proc one(T: typedesc[Coords2D]): Coord2D = (1, 1)
proc one(T: typedesc[Coords3D]): Coord3D = (1, 1, 1)

proc max(cb: AnyCoords): AnyCoord =
    result = AnyCoords.fill(int.low)
    for c in cb:
        result = max(result, c)

proc min(cb: AnyCoords): AnyCoord =
    result = AnyCoords.fill(int.high)
    for c in cb:
        result = min(result, c)

proc `+`(cb: AnyCoords, v: AnyCoord): AnyCoords =
    for i in cb:
        result.excl(v)
        result.incl(i+v)

proc `-`(ca, cb: AnyCoords): AnyCoords =
    for cube in ca:
        if cube notin cb:
            result.incl(cube)

proc `+`(ca, cb: AnyCoords): AnyCoords =
    for cube in ca:
        result.incl(cube)
    for loc in cb:
        result.incl(loc)

proc `&`(ca, cb: AnyCoords): AnyCoords =
    for loc in cb:
        if loc in ca:
            result.incl(loc)

proc neighbours(cb: AnyCoords): AnyCoords =
    for c in cb:
        for loc in AnyCoords.faces:
            result.incl(c+loc)
    result = result - cb

proc allDirections(cb: AnyCoords): seq[AnyCoords] =
    for c in cb:
        for loc in AnyCoords.faces:
            result.add(c+loc)

proc fillBoundary(cmin, cmax: Coord2D): Coords2D =
    for x in cmin[0]..cmax[0]:
        result.incl(coord2d(x, cmin[1]))
        result.incl(coord2d(x, cmax[1]))
    for y in cmin[1]..cmax[1]:
        result.incl(coord2d(cmin[0], y))
        result.incl(coord2d(cmax[0], y))

proc fillBoundary(cmin, cmax: Coord3D): Coords3D =
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

iterator throwNet[AnyCoords, T](cubes: AnyCoords, run: proc (ind: AnyCoords): T): T =
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


# ___________.__        .__                
# \__    ___/|__| _____ |__| ____    ____  
#   |    |   |  |/     \|  |/    \  / ___\ 
#   |    |   |  |  Y Y  \  |   |  \/ /_/  >
#   |____|   |__|__|_|  /__|___|  /\___  / 
#                     \/        \//_____/  

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

# .____                         __  .__                                                            
# |    |    ____   ____ _____ _/  |_|__| ____   ____     _____   ____   _____   ___________ ___.__.
# |    |   /  _ \_/ ___\\__  \\   __\  |/  _ \ /    \   /     \_/ __ \ /     \ /  _ \_  __ <   |  |
# |    |__(  <_> )  \___ / __ \|  | |  (  <_> )   |  \ |  Y Y  \  ___/|  Y Y  (  <_> )  | \/\___  |
# |_______ \____/ \___  >____  /__| |__|\____/|___|  / |__|_|  /\___  >__|_|  /\____/|__|   / ____|
#         \/          \/     \/                    \/        \/     \/      \/              \/     

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

proc rollRight(p: var Positionals, ps, pe: int) =
    for i in ps..pe:
        let rpos = p.index[i]
        inc p.position[rpos]
        if p.position[rpos] > pe:
            p.position[rpos] = ps
    p.data.rollR(ps, pe)
    p.index.rollR(ps, pe)

proc rollLeft(p: var Positionals, ps, pe: int) =
    for i in ps..pe:
        let rpos = p.index[i]
        dec p.position[rpos]
        if p.position[rpos] < ps:
            p.position[rpos] = pe
    p.data.rollL(ps, pe)
    p.index.rollL(ps, pe)

# __________                                                       
# \______   \ ____   ____  __ _________  ______ ___________  ______
#  |       _// __ \_/ ___\|  |  \_  __ \/  ___// __ \_  __ \/  ___/
#  |    |   \  ___/\  \___|  |  /|  | \/\___ \\  ___/|  | \/\___ \ 
#  |____|_  /\___  >\___  >____/ |__|  /____  >\___  >__|  /____  >
#         \/     \/     \/                  \/     \/           \/ 

proc findRoot(fn: proc (v: int): int, maxSteps = int.high, startVal = 1000): int =
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
