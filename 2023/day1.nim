import ../aoc
import sugar, strutils, math, tables

func digits(i: string): seq[char] =
    for c in i:
        if isDigit(c):
            result.add(c)

let tnums = @{"one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
    "six": 6, "seven": 7, "eight": 8, "nine": 9}.toTable

proc funkyDigits(i: string): seq[string] =
    var accumulator: seq[char] = @[]
    for n in 0..<i.len:
        let c = i[n]

        if isDigit(c):
            result.add($c)
            accumulator.setLen(0)
            continue
        
        accumulator.add(c)
        let current = accumulator.join("")
        for k, v in tnums:
            if current.endsWith(k):
                result.add($v)
                # accumulator.setLen(0)
                break


day 1:
    part 1, 54338:
        let truenums = collect:
            for line in lines:
                let nums = line.digits
                parseInt($nums[0] & $nums[^1])
        sum(truenums)

    part 2, 53389:
        let truenums = collect:
            for line in lines:
                let nums = line.funkyDigits
                parseInt($nums[0] & $nums[^1])
        sum(truenums)
