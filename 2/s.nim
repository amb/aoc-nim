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

# Part 2

# b + 1 - a = score/3
# b = (a + score/3 - 1).mod3

proc winLoseReverse(h: (int, int)): int =
    return (h[0] + h[1] - 1).mod3

# 0 = lose, 1 = draw, 2 = win 
# 0 = rock, 1 = paper, 2 = scissors 
doAssert [(0, 0), (0, 1), (0, 2)].mapIt(it.winLoseReverse) == @[2, 0, 1]
doAssert [(1, 0), (1, 1), (1, 2)].mapIt(it.winLoseReverse) == @[0, 1, 2]
doAssert [(2, 0), (2, 1), (2, 2)].mapIt(it.winLoseReverse) == @[1, 2, 0]

let score2 = games.mapIt(it[1] * 3 + (it.winLoseReverse + 1))
echo sum(score2)