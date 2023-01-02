import std/[sequtils, strutils]

type Coord2D = (int, int)

proc mod3(v: int): int = (v + 3) mod 3
proc `-`(a, b: char): int = ord(a) - ord(b)

let lines = """
C Y
B Z
B Z
C Y
B Y
C Z
C Z
C Y
B Z""".strip.splitLines

let parsed = lines.mapIt((it[0]-'A', it[2]-'X'))
echo parsed.mapIt((it[1]+1-it[0]).mod3*3+(it[1]+1))