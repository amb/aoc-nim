import strutils, strformat, sequtils, sugar, algorithm, math, sets
import ../aoc

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

iterator groupsOfThree(): int =
    for group in fil(3, true).partition(3):
        var si = toHashSet(group[0]) * toHashSet(group[1]) * toHashSet(group[2])
        doAssert len(si) == 1, "Set length failure"
        yield priority(si.pop())

echo sum(toSeq(priorities))
echo sum(toSeq(groupsOfThree))
