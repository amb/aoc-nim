import ../aoc
import strutils, tables

func toInt(c: char): int =
    return int(c) - int('0')

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
        var total = 0
        for line in lines:
            var bestB = (line.len, -1)
            var bestE = (-1, -1)
            for ci, c in ["1", "2", "3", "4", "5", "6", "7", "8", "9", 
                "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]:
                let loc = line.find(c)
                if loc >= 0 and loc < bestB[0]:
                    bestB = (loc, ci)
                let eloc = line.rfind(c)
                if eloc >= 0 and eloc > bestE[0]:
                    bestE = (eloc, ci)
            total += bestB[1].asInt * 10 + bestE[1].asInt
        total
