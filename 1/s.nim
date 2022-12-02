import strutils, sequtils, sugar, algorithm, math
let sums = readFile("1/input").split("\n\n").
    map(i => sum(i.split().filterIt(len(it) > 0).mapIt(parseInt(it))))
echo sorted(sums)[^1]

