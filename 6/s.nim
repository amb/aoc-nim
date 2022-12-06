include ../aoc

let data = fil(6)[0]

proc allDifferent(dt: seq[char], count: int): bool =
    # TODO: optimization
    for i in 0..<count:
        for j in 0..<count:
            if i != j and dt[i] == dt[j]:
                return false
    return true

proc findAllDifferent(dt: string, count: int): int =
    var ringBuf = newSeq[char](count)
    var rbLoc: int = 0
    for idx, ch in dt:
        ringBuf[rbLoc] = ch
        rbLoc = (rbLoc + 1) mod count
        if idx >= count and allDifferent(ringBuf, count):
            return idx + 1
    return -1

echo data.findAllDifferent(4)
echo data.findAllDifferent(14)

let sdata = "bvwbjplbgvbhsrlpgdmjqwftvncz"
echo data.slidingWindow(4).toSeq.filter(x => toHashSet(x.view).len == 4)[0].index+4