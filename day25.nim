import aoc
import strutils, tables, math, algorithm, sugar

day 25:
    let numToSnafu = ['=', '-', '0', '1', '2']
    let snafuToNum = {'2': 2, '1': 1, '0': 0, '-': -1, '=': -2}.toTable

    proc desnafu(snum: string): int =
        for i in countdown(snum.high, 0):
            let ch = snum[i]
            let wg = snum.high - i
            result += snafuToNum[ch] * int(pow(5.float, wg.float))

    proc snafu(num: int): string =
        var v = num
        var snum: seq[char]
        while v > 0:
            let rd = (v+2) div 5
            let rr = v+2 - (rd * 5)
            snum.add(numToSnafu[rr])
            v = rd
        snum.reversed.join

    part 1, "2-0=11=-0-2-1==1=-22":
        let ssnaf = collect(for d in lines: desnafu(d)).sum
        snafu(ssnaf)
