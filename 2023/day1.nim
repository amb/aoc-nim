import ../aoc
import sugar, strutils, math, tables

func digits(i: string): seq[char] =
    for c in i:
        if isDigit(c):
            result.add(c)

let tnums = @{"one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
    "six": 6, "seven": 7, "eight": 8, "nine": 9}.toTable

proc endsWithNumber(i: seq[char]): int =
    for k in tnums.keys:
        if i.len < k.len:
            continue
        for n in 1..k.len:
            if i[^n] != k[^n]:
                break
            if n == k.len:
                return tnums[k]
    return 0

proc funkyDigits(i: string): seq[string] =
    var accumulator: seq[char] = @[]
    for n in 0..<i.len:
        let c = i[n]

        if isDigit(c):
            result.add($c)
            accumulator.setLen(0)
            continue
        
        accumulator.add(c)
        let ewn = endsWithNumber(accumulator)
        if ewn != 0:
            result.add($ewn)

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
