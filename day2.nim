include aoc

day 2:
    proc mod3(v: int): int = (v + 3) mod 3
    let parsed: seq[(int, int)] = lines.mapIt((it[0]-'A', it[2]-'X'))
    part 1: sum(parsed.mapIt((it[1]+1-it[0]).mod3*3+(it[1]+1)))
    # part 2: sum(parsed.mapIt(it[1]*3+((it[0]+it[1]-1).mod3+1)))
