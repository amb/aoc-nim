import ../aoc
import ../aoc_lib
import std/[strutils]

proc readThrees(threes: string): seq[array[3, int64]] =
    var lines = threes.split("\n")
    var tbuf: seq[int64]
    var tarr: array[3, int64]
    for line in lines[1..^1]:
        tbuf.setLen(0)
        line.parseUints(tbuf)
        tarr[0] = tbuf[0]
        tarr[1] = tbuf[1]
        tarr[2] = tbuf[2]
        result.add(tarr)

proc checkRange(value: int64, seg: array[3, int64]): int64 =
    if value >= seg[1] and value < seg[1] + seg[2]:
        return (value - seg[1]) + seg[0]
    else:
        return -1

proc filterize(filter: seq[array[3, int64]], value: int64): int64 =
    var lowest = int64.high
    for mapping in filter:
        let cv = checkRange(value, mapping)
        if cv >= 0:
            lowest = min(lowest, cv)
    if lowest != int64.high:
        return lowest
    return value

day 5:
    let lines = input.split("\n\n")

    let seeds = lines[0].parseUInts64()
    var filters: seq[seq[array[3, int64]]]
    for i in 0..<7:
        filters.add(readThrees(lines[i+1]))

    part 1, 157211394:
        var minVal = int64.high
        for seed in seeds:
            var value = seed
            for flt in filters:
                value = flt.filterize(value)
            minVal = min(minVal, value)
        minVal

    part 2, 50855035:
        # brute force 😅
        # TODO: shadowlines
        var minVal = int64.high
        for srange in 0..<seeds.len div 2:
            echo srange
            let rlow = seeds[srange*2]
            let rhigh = seeds[srange*2] + seeds[srange*2+1] - 1
            for seed in rlow..rhigh:
                var value = seed
                for flt in filters:
                    value = flt.filterize(value)
                minVal = min(minVal, value)
        minVal
