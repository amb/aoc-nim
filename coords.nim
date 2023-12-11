import std/[strutils, sequtils, algorithm, math]
import std/[sets, intsets, tables]

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
