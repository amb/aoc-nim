import ../aoc
import ../aoc_lib
import std/[sequtils, strutils, algorithm]

day 9:
    let lines = input.splitLines

    var nums: seq[seq[int]]
    for l in lines:
        let lints = l.ints
        nums.add(lints)

    part 1, 1934898178:
        var totals = 0
        for ni in 0..nums.high:
            var temp = nums[ni]
            var finals: seq[int]
            while temp.count(0) < temp.len:
                finals.add(temp[^1])
                for i in 0..temp.high-1:
                    temp[i] = temp[i+1] - temp[i]
                temp.setLen(temp.len-1)
            finals.reverse
            for i in 0..finals.high-1:
                finals[i+1] += finals[i]
            totals += finals[^1]
        totals

    part 2, 1129:
        var totals = 0
        for ni in 0..nums.high:
            var temp = nums[ni]
            var finals: seq[int]
            while temp.count(0) < temp.len:
                finals.add(temp[0])
                for i in 0..temp.high-1:
                    temp[i] = temp[i+1] - temp[i]
                temp.setLen(temp.len-1)
            finals.reverse
            for i in 0..finals.high-1:
                finals[i+1] -= finals[i]
            totals += finals[^1]
        totals
