import strutils, sequtils, sugar, algorithm, math
let sums = readFile("data/input").split("\n\n").
    map(i => sum(i.split().filterIt(len(it) > 0).mapIt(parseInt(it))))
echo sum(sorted(sums)[^3..^1])
