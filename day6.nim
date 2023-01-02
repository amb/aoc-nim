include aoc

day 6:
    proc solve(wsize: int): int =
        for w in input.slidingWindow(wsize):
            if toHashSet(input[w.a..w.b]).len == wsize:
                return w.a + wsize

    part 1, 1361: solve(4)
    part 2, 3263: solve(14)