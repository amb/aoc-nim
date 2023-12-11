#region NOTES

# Lots of dumb stuff here

# Compiling tips:
# nim c -d:danger -d:strip -d:lto --mm:orc 10/s.nim
# -d:useMalloc?
# --deepCopy?

# beef @ discord
# --hint[Performance]: on
# type MyObject = object
#   a: string
# proc consume(s: sink MyObject) = discard
# proc doThing() =
#   var a = MyObject(a: "hello world")
#   consume(a)
#   echo a
# doThing()
# ...
# /tmp/test.nim(9, 11) Hint: passing 'a' to a sink parameter introduces an implicit copy; if possible, rearrange your program's control flow to prevent it [Performance]
# Make a config.nims or myproject.nims

# For profiling on Windows11/VerySleepy, this works:
# nim c --debugger:native -d:release --mm:arc day15.nim

# Also could look into https://github.com/wolfpld/tracy
# Integration: https://luxeengine.com/integrating-tracy-profiler-in-cpp/

#endregion

import std/[strutils, strformat, sequtils, sugar, algorithm, math, os]
import std/[sets, intsets, tables, re, options, monotimes, times, paths, httpclient]

#    _____         _________
#   /  _  \   ____ \_   ___ \
#  /  /_\  \ /  _ \/    \  \/
# /    |    (  <_> )     \____
# \____|__  /\____/ \______  /
#         \/               \/
#region AOC

proc green*(s: string): string = "\e[32m" & s & "\e[0m"
proc grey*(s: string): string = "\e[90m" & s & "\e[0m"
proc yellow*(s: string): string = "\e[33m" & s & "\e[0m"
proc red*(s: string): string = "\e[31m" & s & "\e[0m"

# https://github.com/MichalMarsalek/Advent-of-code/blob/master/2022/Nim/aoc_logic.nim

var SOLUTIONS*: Table[int, proc (x: string): Table[int, string]]

template day*(day: int, solution: untyped): untyped =
    ## Defines a solution function, if isMainModule, runs it.
    block:
        SOLUTIONS[day] = proc (input: string): Table[int, string] =
            var input {.inject, used.} = input.strip(false)
            var parts {.inject.}: OrderedTable[int, proc (): string]
            solution
            for k, v in parts.pairs:
                result[k] = $v()

    if isMainModule:
        run day

template part*(p: int, solution: untyped): untyped =
    ## Defines a part solution function.
    parts[p] = proc (): string =
        proc inner(): auto =
            solution
        return yellow($inner())

template part*(p: int, answer, solution: untyped): untyped =
    ## Defines a part solution function with test for correctness.
    parts[p] = proc (): string =
        proc inner(): auto =
            solution
        let val = inner()
        if val == answer:
            # return green($val)
            return green("✓")
        else:
            return red($val)

proc getInput(day: int): string =
    let filename = fmt"inputs/day{day}.in"
    if fileExists filename:
        return readFile filename
    echo "Input file not found for day " & $day
    quit(QuitFailure)

proc run*(day: int) =
    if day in SOLUTIONS:
        ## Runs given day solution on the corresponding input.
        let dinp = getInput day
        let start = getMonoTime()
        let results = SOLUTIONS[day](dinp)
        let finish = getMonoTime()

        stdout.write "Day " & $day & ":"
        for k in results.keys.toSeq.sorted:
            stdout.write fmt" [P{k}: {results[k]}]"
        let ttime = (finish-start).inMicroseconds
        if ttime < 10000:
            # Under 10 ms
            stdout.write fmt" {green($ttime)} µs"
        elif ttime < 100000:
            # Under 100 ms
            stdout.write fmt" {$ttime} µs"
        elif ttime < 1000000:
            # Under 1 s
            stdout.write fmt" {yellow($ttime)} µs"
        else:
            stdout.write fmt" {red($ttime)} µs"
        echo ""
    else:
        stdout.write "Day " & $day & ": "
        stdout.write yellow("Missing")
        echo ""

#endregion

# ___________.__        .__
# \__    ___/|__| _____ |__| ____    ____
#   |    |   |  |/     \|  |/    \  / ___\
#   |    |   |  |  Y Y  \  |   |  \/ /_/  >
#   |____|   |__|__|_|  /__|___|  /\___  /
#                     \/        \//_____/
#region TIMING

proc microTime*(t: Duration): (int, int) =
    let mstime = t.inMicroseconds
    let mlsecs = mstime div 1000
    let mcsecs = mstime - (mlsecs * 1000)
    (mlsecs.int, mcsecs.int)

template oneTimeIt*(body: untyped): untyped =
    let timeStart = getMonoTime()
    let val = body
    block:
        let tvals {.inject.} = (getMonoTime() - timeStart).microTime
        echo fmt"Time: {tvals[0]} ms, {tvals[1]} µs"
    val

#endregion
