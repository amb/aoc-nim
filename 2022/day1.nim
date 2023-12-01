import ../aoc
import strutils, sequtils, sugar, math, algorithm, tables

day 1:
    let sums = input.split("\p\p").map(i => sum(i.split("\p").mapIt(parseInt(it)))).sorted
    part 1, 72718: sums[^1]
    part 2, 213089: sum(sums[^3..^1])
