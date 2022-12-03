import strutils, sequtils, sugar, algorithm, math, sets

proc `-`*(a, b: char): int = ord(a) - ord(b)

proc fil*(n: int): seq[string] =
    return readFile($n & "/input").splitLines()

let lowerLetters* = toHashSet(toSeq(ord('a')..ord('z')))
let upperLetters* = toHashSet(toSeq(ord('A')..ord('Z')))
