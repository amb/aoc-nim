import ../aoc
import sequtils, strutils, tables, sets, math, sugar

day 18:
    let cb = input.split.mapIt(it.ints.coord3d).toHashSet
    part 1, 4192: cb.len*6 - Coords3D.faces.mapIt(((cb + it) & cb).len).sum
    part 2, 2520: cb.throwNet(ic => Coords3D.faces.mapIt(((ic + it) & cb).len).sum).toSeq.sum
