include ../aoc
import std/[enumerate, intsets]

var input = collect:
    for (il, line) in enumerate("20/test".readFile.strip.splitLines):
        (value: line.parseInt, index: il)

# Fails on input, not on test:
# assert input.len == input.mapIt(it[0]).deduplicate.len

var positions = toSeq(0..input.len-1)
assert positions.len == input.len

proc swapThem(a, b: int) =
    swap(input[a], input[b])
    swap(positions[input[a].index], positions[input[b].index])

proc rollR[T](a: var seq[T]) =
    let t = a[^1]
    for i in countdown(a.len-1, 1): 
        a[i] = a[i-1]
    a[0] = t

proc rollL[T](a: var seq[T]) =
    let t = a[0]
    for i in countup(0, a.len-2): 
        a[i] = a[i+1]
    a[^1] = t

proc rollRight() =
    input.rollR
    for i in 0..<positions.len:
        inc positions[i]
        if positions[i] >= positions.len:
            positions[i] = 0

proc rollLeft() =
    input.rollL
    for i in 0..<positions.len:
        dec positions[i]
        if positions[i] < 0:
            positions[i] = positions.len-1

for i in 0..input.len-1:
    let loc = positions[i]
    let dir = input[loc].value.sgn
    if dir == 0:
        continue
    echo fmt"Move {input[positions[i]].value} at {positions[i]}"
    var aloc = loc
    var bloc = loc+dir
    var counter = abs(input[loc].value)
    while counter > 0:
        assert positions.mapIt(input[it].value) == @[1, 2, -3, 3, -2, 0, 4], $counter
        if bloc >= input.len:
            rollRight()
            bloc = 0
            inc counter
        elif bloc < 0:
            rollLeft()
            bloc = input.len - 1
            inc counter
        else:
            assert abs(aloc-bloc) < 2
            swapThem(aloc, bloc)
        bloc = bloc+dir
        aloc = (aloc+dir).floorMod(input.len)
        dec counter
    echo input.mapIt(it.value)
    # echo positions
    assert positions.mapIt(input[it].value) == @[1, 2, -3, 3, -2, 0, 4]
    # echo positions

echo "---"
echo input
echo input.mapIt(it.value)
echo positions
