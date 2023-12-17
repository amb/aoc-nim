import ../aoc
import ../aoc_lib
import std/[strutils]

day 6:
    let lines = input.splitLines
    let times = lines[0].parseUints64
    let distances = lines[1].parseUints64

    proc calculate(time: int64, distance: int64): int64 =
        var recordBeat = 0
        for pressed in 0..time:
            let speed = pressed
            let timeRemainder = time - pressed
            let distanceTraveled = speed * timeRemainder
            if distanceTraveled > distance:
                inc recordBeat
        recordBeat

    part 1, 393120:
        var totals = 1
        for games in 0..<times.len:
            totals *= calculate(times[games], distances[games])
        totals

    part 2, 36872656:
        # Another brute-force 😓
        calculate(62737565, 644102312401023)
