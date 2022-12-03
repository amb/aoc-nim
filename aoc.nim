import strutils, sequtils, sugar, algorithm, math, sets

proc `-`*(a, b: char): int = ord(a) - ord(b)

proc fil*(n: int): seq[string] =
    return readFile($n & "/input").splitLines()

let lowerLetters* = toHashSet(toSeq(ord('a')..ord('z')))
let upperLetters* = toHashSet(toSeq(ord('A')..ord('Z')))

proc partition*[T](i: seq[T], ps: int): seq[seq[T]] =
    doAssert len(i) mod ps == 0, fmt"Seq len {len(i)} not divisible with {ps}"
    var os: seq[seq[T]] = newSeq[seq[T]]()
    var c: seq[T]
    var ci = 0
    for v in i:
        c.add(v)
        ci += 1
        if ci == ps:
            ci = 0
            os.add(c)
            c.setLen(0)
    return os

