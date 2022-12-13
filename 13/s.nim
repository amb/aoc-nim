include ../aoc

# : is ascii code after 9
let data = "13/input".readFile.multiReplace(("10", ":")).strip

proc `>`(a, b: char): bool = ord(a) > ord(b)

# TODO: const enum instead of magic numbers
proc isNum(a: char): bool =
    if a == '[' or a == ']' or a == ',': return false
    return true

proc isRightOrder(x, y: string): int =
    var pt0 = 0
    var pt1 = 0
    var pkt0 = y
    var pkt1 = x
    while pt0 < pkt0.len and pt1 < pkt1.len:
        let ch0 = pkt0[pt0]
        let ch1 = pkt1[pt1]
        if ch0 != ch1:
            if isNum(ch0) and isNum(ch1):
                if ch0 > ch1:
                    return -1
                if ch1 > ch0:
                    return 1
            if isNum(ch0) and ch1=='[':
                pkt0 = pkt0[0..<pt0] & "[" & ch0 & "]" & pkt0[pt0+1..^1]
                pkt0[pt0] = '['
            elif isNum(ch1) and ch0=='[':
                pkt1 = pkt1[0..<pt1] & "[" & ch1 & "]" & pkt1[pt1+1..^1]
                pkt1[pt1] = '['
            if ch1==']' and ch0!=']':
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
echo "Part 1: ", answer.sum

var lines = data.split("\n").filterIt(it.len > 0)
lines.add("[[2]]")
lines.add("[[6]]")
lines.sort(isRightOrder)
echo "Part 2: ", (lines.findIf(x => x=="[[6]]")+1) * (lines.findIf(x => x=="[[2]]")+1)

# 3446 too low
# 5292 part 1 right 8:30
# part 2 8:49