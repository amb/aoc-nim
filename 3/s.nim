import strutils, strformat, sequtils, sugar, algorithm, math, sets
import ../aoc

# for i in 0 .. 25:
#     echo chr(i+ord('a')) & " " & chr(i+ord('A'))
# a->z = 1->25
# A->Z = 27-52


proc priority(c: char): int =
    doAssert isAlphaAscii(c)
    if isLowerAscii(c): c-'a'+1
    elif isUpperAscii(c): c-'A'+27
    else: 0

iterator priorities(): int =
    for line in fil(3):
        doAssert len(line) mod 2 == 0
        let ll = len(line) div 2
        var si = intersection(toHashSet(line[0..<ll]), toHashSet(line[ll..<line.len]))
        if len(si) == 0:
            continue
        yield priority(si.pop())

iterator prioritiesB(): int =
    for group in fil(3).filterIt(len(it) > 0).partition(3):
        if len(group) != 3:
            # echo "no3"
            continue
        var si = intersection(toHashSet(group[0]), toHashSet(group[1]))
        si = intersection(si, toHashSet(group[2]))
        if len(si) == 0:
            continue
        doAssert len(si) == 1
        yield priority(si.pop())

echo sum(toSeq(prioritiesB))

# echo sum()