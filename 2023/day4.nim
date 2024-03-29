import ../[aoc, aoc_lib]
import std/[strutils, tables, math, intsets]

day 4:
    let lines = input.splitLines
    var amounts = newSeq[int](lines.len)
    var total1, total2 = 0
    var nums = newSeq[int](0)
    var winning: IntSet
    for index, l in lines:
        l.parseUints(nums)

        var mat = 0
        winning.clear
        for i in 1..10:
            winning.incl(nums[i])
        for i in 11..nums.high:
            if nums[i] in winning:
                inc mat
        nums.setLen(0)

        total1 += (if mat > 0: 2^(mat-1) else: 0)
        inc amounts[index]
        total2 += amounts[index]
        var endPoint = min(index + mat, amounts.high)
        for i in index+1..endPoint:
            amounts[i] += amounts[index]

    part 1, 15205: total1
    part 2, 6189740: total2

# nim c --cc:gcc --debugger:native -d:release --threads:off day4.nim
