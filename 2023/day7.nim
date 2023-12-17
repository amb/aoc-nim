import ../aoc
import ../aoc_lib
import std/[sequtils, strutils, tables, algorithm, math]


const cardMappingB = {'A': 12, 'K': 11, 'Q': 10, 'T': 9, '9': 8,
    '8': 7, '7': 6, '6': 5, '5': 4, '4': 3, '3': 2, '2': 1, 'J': 0}.toTable


const cardMapping = {'A': 12, 'K': 11, 'Q': 10, 'J': 9, 'T': 8,
    '9': 7, '8': 6, '7': 5, '6': 4, '5': 3, '4': 2, '3': 1, '2': 0}.toTable


type HandComponents = tuple[pairs: int, triples: int, four: int, five: int, jokers: int]


type HandType = enum
    HighCard, OnePair, TwoPairs, ThreeOfAKind, FullHouse, FourOfAKind, FiveOfAKind


proc calcRank(hand: HandComponents): HandType =
    if hand.five == 1:
        # five of a kind
        # 55555
        # JJJJJ
        result = FiveOfAKind
    elif hand.four == 1:
        # four of a kind
        # 4444Q
        result = FourOfAKind
        if hand.jokers == 1:
            # 5555J
            result = FiveOfAKind
        if hand.jokers == 4:
            # JJJJ5
            result = FiveOfAKind
    elif hand.pairs == 1 and hand.triples == 1:
        # full house
        # 33322
        result = FullHouse
        if hand.jokers == 2:
            # 333JJ
            result = FiveOfAKind
        if hand.jokers == 3:
            # JJJ33
            result = FiveOfAKind
    elif hand.triples == 1:
        # three of a kind
        # 333QT
        result = ThreeOfAKind
        if hand.jokers == 1:
            # 333JT
            result = FourOfAKind
        if hand.jokers == 3:
            # JJJQT
            result = FourOfAKind
    elif hand.pairs == 2:
        # two pairs
        # 2233Q
        result = TwoPairs
        if hand.jokers == 1:
            # becomes full house
            # 2233J
            result = FullHouse
        if hand.jokers == 2:
            # becomes four of a kind
            # 22JJQ
            result = FourOfAKind
    elif hand.pairs == 1:
        # one pair
        # 22KQT
        result = OnePair
        if hand.jokers == 1:
            # becomes three of a kind
            # 22KJT
            result = ThreeOfAKind
        if hand.jokers == 2:
            # becomes three of a kind
            # JJKQT
            result = ThreeOfAKind
    else:
        # high card
        # 2KQT9
        if hand.jokers == 1:
            # becomes one pair
            # 2KQTJ
            result = OnePair


proc countCards(s: string, mapping: Table[char, int]): HandComponents =
    var cardCounts: array[13, int]

    for c in s:
        inc cardCounts[mapping[c]]
        if c == 'J':
            inc result.jokers

    for i in 0..12:
        if cardCounts[i] == 2:
            inc result.pairs
        elif cardCounts[i] == 3:
            inc result.triples
        elif cardCounts[i] == 4:
            inc result.four
        elif cardCounts[i] == 5:
            inc result.five


proc handValue(s: string, mapping: Table[char, int], jokersExist = false): int64 =
    var hcmp = countCards(s, mapping)

    if not jokersExist:
        hcmp.jokers = 0

    var totalValue: int64 = calcRank(hcmp).ord * 16
    for c in s:
        totalValue += mapping[c]
        totalValue *= 16

    return totalValue


const testInput = """32T3K 765
T55J5 684
KK677 28
KTJJT 220
QQQJA 483"""


day 7:
    let lines = input.splitLines

    var hands: seq[tuple[cards: string, bet: int]]
    for line in lines:
        let parts = line.split(" ")
        hands.add((parts[0], parts[1].parseInt))

    part 1, 246163188:
        proc cmp1(x, y: tuple[cards: string, bet: int]): int =
            let thvx = handValue(x.cards, cardMapping)
            let thvy = handValue(y.cards, cardMapping)
            return sgn(thvx - thvy)

        hands.sort(cmp1)
        var totals = 0
        for hi, h in hands:
            totals += (hi+1) * h.bet

        totals
        # 254837312 too high
        # 246163188 correct

    part 2:
        proc cmp2(x, y: tuple[cards: string, bet: int]): int =
            let thvx = handValue(x.cards, cardMappingB, true)
            let thvy = handValue(y.cards, cardMappingB, true)
            return sgn(thvx - thvy)

        hands.sort(cmp2)
        for hi, h in hands:
            # if 'J' in h.cards:
            var totalValue = calcRank(countCards(h.cards, cardMappingB))
            echo h.cards, " -> ", totalValue

        var totals = 0
        for hi, h in hands:
            totals += (hi+1) * h.bet

        totals
        # 245724373 too low
        # 245781267 too low
        # 245794069 correct
        # 246238256 too high
