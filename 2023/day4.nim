import ../aoc
import std/[sequtils, strutils, sets, tables, math]

day 4:
    let lines = input.splitLines

    type Scratch = object
        index: int
        winning: HashSet[int]
        own: HashSet[int]
        cardValue: int
        matching: int
        amount: int

    var cards = newSeq[Scratch](lines.len)

    proc calcValue(c: var Scratch) =
        var cval = 0
        var mat = 0
        for n in c.winning:
            if n in c.own:
                inc mat
                if cval == 0:
                    cval = 1
                else:
                    cval *= 2
        c.cardValue = cval
        c.matching = mat

    var total1 = 0
    for index, l in lines:
        let nums = ints(l)
        cards[index] = Scratch(index: nums[0], winning: nums[1..10].toSet, own: nums[11..^1].toSet, amount: 1)
        cards[index].calcValue()
        total1 += cards[index].cardValue

    assert cards[1].index == 2

    part 1, 15205:
        total1

    part 2, 6189740:
        for idx, c in cards:
            var endPoint = idx + c.matching
            if endPoint > cards.high:
                endPoint = cards.high
            for i in idx+1..endPoint:
                cards[i].amount += c.amount
            
        cards.mapIt(it.amount).sum
