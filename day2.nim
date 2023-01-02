include aoc

proc mod3(v: int): int = (v + 3) mod 3

day 2:
    let parsed = lines.mapIt((it[0]-'A', it[2]-'X'))
    part 1, 13268: (parsed.mapIt((it[1]+1-it[0]).mod3*3+(it[1]+1))).sum
    part 2, 15508: (parsed.mapIt(it[1]*3+((it[0]+it[1]-1).mod3+1))).sum
