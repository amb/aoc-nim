# Constantine
# Copyright (c) 2018-2019    Status Research & Development GmbH
# Copyright (c) 2020-Present Mamy André-Ratsimbazafy
# Licensed and distributed under either of
#   * MIT license (license terms in the root directory or at http://opensource.org/licenses/MIT).
#   * Apache v2 license (license terms in the root directory or at http://www.apache.org/licenses/LICENSE-2.0).
# at your option. This file may not be copied, modified, or distributed except according to those terms.

# with some modifications

import
  std/[macros, times, monotimes]

# Only works in single threaded cases
assert defined(threads) == false

proc atomicInc*(memLoc: var int64, x = 1'i64): int64 =
    memloc += x
    result = memLoc

type
  Metadata* = object
    procName*: string
    numCalls*: int64
    cumulatedTimeMicros*: int64

var ctMetrics{.compileTime.}: seq[Metadata]
  ## Metrics are collected here, this is just a temporary holder of compileTime values
  ## Unfortunately the "seq" is emptied when passing the compileTime/runtime boundaries
  ## due to Nim bugs

# strformat doesn't work in templates.
from strutils import alignLeft, formatFloat

var Metrics*: seq[Metadata]
  ## We can't directly use it at compileTime because it doesn't exist.
  ## We need `Metrics = static(ctMetrics)`
  ## To transfer the compileTime content to runtime at an opportune time.

proc resetMetering*() =
  Metrics = static(ctMetrics)

# Symbols
# --------------------------------------------------

template fnEntry(name: string, id: int, startTime, startCycle: untyped): untyped =
  ## Bench tracing to insert on function entry
  {.noSideEffect, gcsafe.}:
    discard Metrics[id].numCalls.atomicInc()
    let startTime = getMonoTime()
    let startCycle = 0

template fnExit(name: string, id: int, startTime, startCycle: untyped): untyped =
  ## Bench tracing to insert before each function exit
  {.noSideEffect, gcsafe.}:
    let stopTime = getMonoTime()
    let elapsedTime = inMicroseconds(stopTime - startTime)
    discard Metrics[id].cumulatedTimeMicros.atomicInc(elapsedTime)

    # Advice: Use "when name == relevantProc" to isolate specific procedures.
    # strformat doesn't work in templates.
    # echo static(alignLeft(name, 50)),
    #   "Time (µs): ", alignLeft(formatFloat(elapsedTime.float64 * 1e-3, precision=3), 10)

macro meterAnnotate(procAst: untyped): untyped =
  procAst.expectKind({nnkProcDef, nnkFuncDef})

  let id = ctMetrics.len
  let name = procAst[0].repr

  ctMetrics.add Metadata(procName: name)
  var newBody = newStmtList()
  let startTime = genSym(nskLet, "metering_" & name & "_startTime_")
  let startCycle = genSym(nskLet, "metering_" & name & "_startCycles_")
  newBody.add getAst(fnEntry(name, id, startTime, startCycle))
  newbody.add nnkDefer.newTree(getAst(fnExit(name, id, startTime, startCycle)))
  newBody.add procAst.body

  procAst.body = newBody
  result = procAst

template meter*(procBody: untyped): untyped =
  meterAnnotate(procBody)
