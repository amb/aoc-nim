include ../aoc
import ../tracer
import std/[monotimes, times, streams]
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

proc anyDigit(s: string): bool =
    result = false
    for i in s:
        if i.isDigit:
            result = true

proc solve1(data: string): int {.meter.} =
    data.pieces("\n\n") --> 
        map(data[it].stringSplit('\n')).
        indexedMap(isRightOrder(it[0], it[1])).
        map(if it.elem < 0: it.idx+1 else: 0).sum()

proc solve2(data: string): int {.meter.} =
    # Skip empty lines, count and ignore un-numbered lines
    var count = 0
    var lines: seq[string]
    for line in data.pieces("\n"):
        let s = data[line]
        if s.len > 0:
            inc count
            if s.anyDigit:
                lines.add(s)
                
    let diff = count - lines.len
    lines.add("[[2]]")
    lines.add("[[6]]")
    lines.sort(isRightOrder)
    (lines.findIf(x => x=="[[6]]")+1+diff) * (lines.findIf(x => x=="[[2]]")+1+diff)

metricsConfirm()

var timeStart = getMonoTime()

let data = "13/input".readFile

let part1 = solve1(data)
let part2 = solve2(data)

let mstime = (getMonoTime() - timeStart).inMicroseconds
let mlsecs = mstime div 1000
let mcsecs = mstime - (mlsecs * 1000)
echo "Time: ", mlsecs,".", mcsecs, " ms"
echo "Part 1: ", part1
if part1 != 5292: echo "\n>>> PART 1 TEST FAILURE <<<\n"
echo "Part 2: ", part2
if part2 != 23868: echo "\n>>> PART 2 TEST FAILURE <<<\n"

metricsShow()