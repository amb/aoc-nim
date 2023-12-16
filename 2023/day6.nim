import ../aoc
import ../aoc_lib
import std/[sequtils, strutils]

const testInput = """Time:      7  15   30
Distance:  9  40  200"""

day 6:
    let lines = input.splitLines
    # let lines = testInput.splitLines
    let times = lines[0].parseUints64
    let distances = lines[1].parseUints64

    part 1, 393120:
        var totals = 1
        for games in 0..<times.len:
            let time = times[games]
            let distance = distances[games]
            var recordBeat = 0
            for pressed in 0..time:
                let speed = pressed
                let timeRemainder = time - pressed
                let distanceTraveled = speed * timeRemainder
                if distanceTraveled > distance:
                    inc recordBeat
            totals *= recordBeat

        totals

    part 2:
        # Another brute-force 😓

        let time: int64 = 62737565
        let distance: int64 = 644102312401023

        var totals = 1
        var recordBeat = 0
        for pressed in 0..time:
            let speed = pressed
            let timeRemainder = time - pressed
            let distanceTraveled = speed * timeRemainder
            if distanceTraveled > distance:
                inc recordBeat
        totals *= recordBeat

        totals

