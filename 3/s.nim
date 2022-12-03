import strutils, sequtils, sugar, algorithm, math, sets
import ../aoc

# for i in 0 .. 25:
#     echo chr(i+ord('a')) & " " & chr(i+ord('A'))
# a->z = 1->25
# A->Z = 27-52

iterator priorities(): int =
    for line in fil(3):
        doAssert len(line) mod 2 == 0
        let ll = len(line) div 2
        var si = intersection(toHashSet(line[0..<ll]), toHashSet(line[ll..<line.len]))
        if len(si) == 0:
            continue
        let c = si.pop()
        doAssert isAlphaAscii(c)
        yield (if isLowerAscii(c): 
                ord(c)-ord('a')+1
            elif isUpperAscii(c): 
                ord(c)-ord('A')+27
            else: 0)

echo sum(toSeq(priorities))

# echo sum()