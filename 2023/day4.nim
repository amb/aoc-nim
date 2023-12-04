import ../aoc
import std/[sequtils, strutils, sets, tables, math, intsets]

day 4:
    let lines = input.splitLines

    type Scratch = object
        index: int
        winning: IntSet
        own: IntSet
        cardValue: int
        matching: int
        amount: int

    var cards = newSeq[Scratch](lines.len)

    proc calcValue(c: var Scratch) =
        let mat = (c.winning * c.own).len
        c.cardValue = (if mat > 0: 2^(mat-1) else: 0)
        c.matching = mat

    var total1 = 0
    for index, l in lines:
        let nums = ints(l)
        cards[index] = Scratch(index: nums[0], winning: nums[1..10].toIntSet, own: nums[11..^1].toIntSet, amount: 1)
        cards[index].calcValue()
        total1 += cards[index].cardValue

    part 1, 15205: total1
    part 2, 6189740:
        for idx, c in cards:
            var endPoint = idx + c.matching
            if endPoint > cards.high:
                endPoint = cards.high
            for i in idx+1..endPoint:
                cards[i].amount += c.amount
        cards.mapIt(it.amount).sum
