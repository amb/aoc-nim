import strutils, sequtils, sugar, algorithm, math

proc `-`(a, b: char): int = ord(a) - ord(b)

#  RPS <- player
# R360
# P036
# S603

# 0: lose, 3: draw, 6: win
proc mod3(v: int): int = (v + 3) mod 3
proc winLose(h: (int, int)): int =
    return (h[1] + 1 - h[0]).mod3 * 3

doAssert [(0, 0), (0, 1), (0, 2)].mapIt(it.winLose) == @[3, 6, 0]
doAssert [(1, 0), (1, 1), (1, 2)].mapIt(it.winLose) == @[0, 3, 6]
doAssert [(2, 0), (2, 1), (2, 2)].mapIt(it.winLose) == @[6, 0, 3]

let lines = readFile("2/input").splitLines().filterIt(len(it) > 2)
let games = lines.mapIt((it[0] - 'A', it[2] - 'X'))
let score = games.mapIt(it.winLose + (it[1] + 1))
echo sum(score)
