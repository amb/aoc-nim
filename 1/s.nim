include ../aoc
let sums = readFile("1/input").split("\n\n").
    map(i => sum(i.split().filterIt(len(it) > 0).mapIt(parseInt(it)))).sorted
echo sums[^1]
echo sum(sums[^3..^1])

