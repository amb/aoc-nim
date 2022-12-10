include ../aoc

var chkPt = @[20, 60, 100, 140, 180, 220].reversed
var cycle = 1
var X = 1

proc solve(line: string): int =
    inc cycle
    if line[0] in {'0'..'9', '-'}:
        X += parseInt(line.strip)
    if chkPt.len > 0 and cycle == chkPt[^1]:
        result = chkPt.pop() * X

let signal = collect:
    for line in readFile("10/input").split({'\n', ' '}): line.solve

echo signal.sum
