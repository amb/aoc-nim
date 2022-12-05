include ../aoc

let lines = fil(5)
let numsLoc = findIf(lines, x => x[1].isDigit)
doAssert len(lines[numsLoc]) == 35 # 3*9 + 8

# Parse the input into arrays
var stacks = newSeq[seq[char]](9)
for l in countdown(numsLoc-1, 0):
    for n in 1..9:
        let loc = 1 + (n-1)*4
        let ch = lines[l][loc]
        if ch.isAlphaAscii:
            stacks[n-1].add(ch)

let moves = collect:
    for line in lines[numsLoc+1..<lines.len]:
        let (success, count, a, b) = line.scanTuple("move $i from $i to $i")
        if success:
            (count: count, a: a-1, b: b-1)

# TODO: what are the move semantics here?
#       Is this deep copy or something else?
var stacksB = stacks

for m in moves:
    for i in 0..<m.count:
        stacks[m.b].add(stacks[m.a].pop())

for s in 0..8:
    stdout.write stacks[s][^1]

# Part 2

for m in moves:
    stacksB[m.b] &= stacksB[m.a][^m.count..^1]
    stacksB[m.a].setLen(stacksB[m.a].len - m.count)

echo "\nPart 2"
for s in 0..8:
    stdout.write stacksB[s][^1]
