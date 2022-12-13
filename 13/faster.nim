include ../aoc
import ../tracer
import std/[monotimes, times]
import zero_functional

proc `>`(a, b: char): bool  {.inline.} = ord(a) > ord(b)
proc isNum(a: char): bool {.inline.} = not (a == '[' or a == ']' or a == ',')

proc isRightOrder(x, y: string): int {.meter.} =
    var pt0 = 10
    var pt1 = 10
    # Hacky, will crash on bigger input
    var pkt0 = "          " & y
    var pkt1 = "          " & x
    while pt0 < pkt0.len and pt1 < pkt1.len:
        var ch0 = pkt0[pt0]
        var ch1 = pkt1[pt1]
        # Instead of multireplace("10", ":"), do this
        if ch0 == '1' and pkt0[pt0+1] == '0':
            pkt0[pt0+1] = ':'
            ch0 = ':'
            inc pt0
        if ch1 == '1' and pkt1[pt1+1] == '0':
            pkt1[pt1+1] = ':'
            ch1 = ':'
            inc pt1
        # Actual rules part
        if ch0 != ch1:
            if isNum(ch0) and isNum(ch1):
                if ch0 > ch1:
                    return -1
                if ch1 > ch0:
                    return 1
            elif isNum(ch0) and ch1=='[':
                pkt0[pt0-2] = '['
                pkt0[pt0-1] = ch0
                pkt0[pt0] = ']'
                pt0 -= 2
            elif isNum(ch1) and ch0=='[':
                pkt1[pt1-2] = '['
                pkt1[pt1-1] = ch1
                pkt1[pt1] = ']'
                pt1 -= 2
            elif ch1==']' and ch0!=']':
                return -1
            elif ch0==']' and ch1!=']':
                return 1
        inc pt0
        inc pt1
    return 1

iterator pieces(s: string, stopper: string): Slice[int] =
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

proc tupleSplit(s: string, stopper: char): (string, string) =
    var loc = 0
    while loc < s.len:
        if s[loc] == stopper:
            return (s[0..<loc], s[loc+1..s.len-1])
        inc loc
    return (s, "")

proc solve1(data: string): int {.meter.} =
    data.pieces("\n\n") --> 
        map(data[it].tupleSplit('\n')).
        indexedMap(isRightOrder(it[0], it[1])).
        map(((-(it.elem-1))*(it.idx+1)) shr 1).sum()

proc solve2(data: string): int {.meter.} =
    var lines = data.pieces("\n") --> map(data[it]).filter(it.len > 0)
    lines.add("[[2]]")
    lines.add("[[6]]")
    lines.sort(isRightOrder)
    (lines.findIf(x => x=="[[6]]")+1) * (lines.findIf(x => x=="[[2]]")+1)

resetMetering()

var timeStart = getMonoTime()

let data = "13/input".readFile

let part1 = solve1(data)
let part2 = solve2(data)

let mstime = (getMonoTime() - timeStart).inMicroseconds
let mlsecs = mstime div 1000
let mcsecs = mstime - (mlsecs * 1000)
echo "Time: ", mlsecs,".", mcsecs, " ms"
echo "Part 1: ", part1
assert part1 == 5292
echo "Part 2: ", part2
assert part2 == 23868

for m in Metrics:
    echo m
