import strutils, sequtils, sugar, algorithm, math
let sums = sorted(readFile("1/input").split("\n\n").
    map(i => sum(i.split().filterIt(len(it) > 0).mapIt(parseInt(it)))))
echo sums[^1]
echo sum(sums[^3..^1])

