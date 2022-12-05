import strutils, strformat, sequtils, sugar, algorithm, math, sets, strscans
import ../aoc

proc isInside(a, b, x, y: int): bool =
    (a >= x and b <= y) or (x >= a and y <= b)

proc anyOverlap(a, b, x, y: int): bool =
    ((a >= x and a <= y) or (b >= x and b <= y)) or 
    ((x >= a and x <= b) or (y >= a and y <= b))

var insideCount = 0
var overlapCount = 0
for ln, line in fil(4):
    var a, b, x, y: int
    if not line.strip.scanf("$i-$i,$i-$i", a, b, x, y):
        continue
    insideCount += (if isInside(a, b, x, y): 1 else: 0)
    overlapCount += (if anyOverlap(a, b, x, y): 1 else: 0)

echo insideCount
echo overlapCount