import std/[strutils, strformat, sequtils, sugar, algorithm, math, os]
import std/[sets, intsets, tables, re, options, monotimes, times, paths, httpclient]

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

proc dims*(s: seq[string]): (int, int) =
    (s[0].len, s.len)

proc parseUints*(s: string, nums: var seq[int]) =
    var inNum = false
    var startLoc = 0
    for ci, c in s:
        let digit = c.isDigit
        if digit and not inNum:
            inNum = true
            startLoc = ci
        elif not digit and inNum:
            inNum = false
            nums.add s[startLoc..ci-1].parseInt
    if inNum:
        nums.add s[startLoc..^1].parseInt


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


