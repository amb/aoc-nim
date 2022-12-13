include ../aoc
import std/[monotimes, times]
# import nimprof

var timeStart = getMonoTime()

# : is ascii code after 9
let data = "13/input".readFile

# var dataPt = 0
# proc dataLine(): string =
#     var res: seq[char]
#     while data[dataPt] != '\n':
#         res.add(data[dataPt])
#         inc dataPt
#     inc dataPt
#     return res.join

proc `>`(a, b: char): bool  {.inline.} = ord(a) > ord(b)
proc isNum(a: char): bool {.inline.} = not (a == '[' or a == ']' or a == ',')

proc isRightOrder(x, y: string): int =
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

let data1 = data.split("\n\n")
let answer = collect:
    for il, l in data1:
        var pkt = l.splitLines 
        if isRightOrder(pkt[0], pkt[1]) < 0: il+1 else: 0
let part1 = answer.sum

var lines = data.split("\n").filterIt(it.len > 0)
lines.add("[[2]]")
lines.add("[[6]]")
lines.sort(isRightOrder)
let part2 = (lines.findIf(x => x=="[[6]]")+1) * (lines.findIf(x => x=="[[2]]")+1)

let mstime = (getMonoTime() - timeStart).inMicroseconds
let mlsecs = mstime div 1000
let mcsecs = mstime - (mlsecs * 1000)
echo "Time: ", mlsecs,".", mcsecs, " ms"
echo "Part 1: ", part1
assert part1 == 5292
echo "Part 2: ", part2
assert part2 == 23868
