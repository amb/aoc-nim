include aoc

day 1:
    let sums = input.split("\n\n").map(i => sum(i.split.mapIt(parseInt(it)))).sorted
    part 1, 72718: sums[^1]
    part 2, 213089: sum(sums[^3..^1])

