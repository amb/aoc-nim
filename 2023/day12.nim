import ../aoc
import ../aoc_lib
import std/[sequtils, strutils, strformat, enumerate, tables, sets, math, options, algorithm]

const testInput = """???.### 1,1,3
.??..??...?##. 1,1,3
?#?#?#?#?#?#?#? 1,3,1,6
????.#...#... 4,1,1
????.######..#####. 1,6,5
?###???????? 3,2,1"""

# tip from Reddit

# well, you could analyze the string left to right.
# if it starts with a ., discard the . and recursively check again.
# if it starts with a ?, replace the ? with a . and recursively check again, AND replace it with a # and recursively check again.
# it it starts with a #, check if it is long enough for the first group, check if all characters in the first [grouplength] characters are not '.', and then remove the first [grouplength] chars and the first group number, recursively check again.
# at some point you will get to the point of having an empty string and more groups to do - that is a zero. or you have an empty string with zero gropus to do - that is a one.
# there are more rules to check than these few, which are up to you to find. but this is a way to work out the solution.

day 12:
    let lines = testInput.splitLines

    type Springs = object
        good: string
        strips: seq[int]

    var report: seq[Springs]
    for l in lines:
        let parts = l.split(" ")
        report.add(Springs(good: parts[0], strips: parts[1].ints))

    proc possibleFit(s: string, l, loc: int): bool =
        if loc+l > s.len:
            return false
        for i in loc..<loc+l:
            if s[i] == '.':
                return false
        if loc > 0 and s[loc-1] == '#':
            return false
        if loc+l < s.len and s[loc+l] == '#':
            return false
        return true

    type DFS_State = object
        perms: int
        maxDepth: int

    proc dfs(s: string, sloc: int, strips: seq[int], depth = 0): int =
        # find first possible
        let spd = strips[depth]
        for i in sloc..s.len-spd:
            if s.possibleFit(spd, i):
                if depth < strips.len - 1:
                    result += s.dfs(i+spd+1, strips, depth+1)
                else:
                    inc result






    # per problem line
    for ri, r in report:
        # per continuous strip
        echo r.good, " -> ", dfs(r.good, 0, r.strips)

    part 1:
        404

    part 2:
        404
