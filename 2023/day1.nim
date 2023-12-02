import ../aoc
import strutils, tables, strformat

func toInt(c: char): int = int(c) - int('0')

type AccParse = object
    names: seq[string]
    locs: seq[int]

proc newAccParse(names: seq[string]): AccParse =
    result = AccParse(names: names, locs: newSeq[int](names.len))

proc parse(ap: var AccParse, c: char): int =
    result = -1
    for ni, n in ap.names:
        if n[ap.locs[ni]] == c:
            ap.locs[ni] = ap.locs[ni] + 1
        else:
            # ffive
            ap.locs[ni] = (if n[0] != c: 0 else: 1)

        if ap.locs[ni] == n.len:
            result = ni
            break

proc parseReverse(ap: var AccParse, c: char): int =
    result = -1
    for ni, n in ap.names:
        if n[ap.locs[ni]] == c:
            ap.locs[ni] = ap.locs[ni] - 1
        else:
            ap.locs[ni] = (if n[n.len - 1] != c: n.len - 1 else: n.len - 2)

        if ap.locs[ni] == -1:
            result = ni
            break

proc reset(ap: var AccParse) =
    for ni in 0..<ap.names.len:
        ap.locs[ni] = 0

proc resetReverse(ap: var AccParse) =
    for ni in 0..<ap.names.len:
        ap.locs[ni] = ap.names[ni].len - 1


day 1:
    part 1, 54338:
        var total = 0
        for line in lines:
            for c in line:
                if isDigit(c):
                    total += c.toInt * 10
                    break
            for ci in countdown(line.high, line.low):
                let c = line[ci]
                if isDigit(c):
                    total += c.toInt
                    break
        total

    part 2, 53389:
        func asInt(s: int): int = (if s < 9: s + 1 else: s - 8)
        const numbers = ["1", "2", "3", "4", "5", "6", "7", "8", "9", 
                "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]

        var pac = newAccParse(@numbers)

        var total = 0
        for line in lines:
            pac.resetReverse
            for ci in countdown(line.high, line.low):
                let c = line[ci]
                let r = pac.parseReverse(c)
                if r >= 0:
                    total += r.asInt()
                    break

            pac.reset
            for ci, c in line:
                let r = pac.parse(c)
                if r >= 0:
                    total += r.asInt() * 10
                    break
        total
