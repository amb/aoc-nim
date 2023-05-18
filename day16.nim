import aoc_logic
import std/[deques, strutils, strformat, sequtils, tables, hashes, sets]
import memo

type
    Valve = ref object
        name: string
        rate: int
        open: bool
        nodes: HashSet[Valve]

proc hash(x: Valve): Hash =
    hash(x.name)

proc `$`(v: Valve): string =
    const csep = ", "
    fmt"{v.rate} ({v.nodes.mapIt(it.name).join(csep)})"

proc parse(fl: string): Table[string, Valve] =
    let data = fl.readFile.strip.splitLines
    var valves: Table[string, Valve]
    for line in data:
        valves[line[6..7]] = Valve(name: line[6..7], rate: line.ints[0])

    for line in data:
        valves[line[6..7]].nodes = line.split(", ").mapIt(valves[it[^2..^1]]).toHashSet

    # Check that the graph is bi-directional
    for v in valves.values:
        for cv in v.nodes:
            assert v in cv.nodes
    valves

var valves = parse("16/test")
echo valves

# find the valve with minimum rate in a list of valves
proc minRate(v: seq[Valve]): Valve =
    var mval = v[0]
    for cv in v:
        if cv.rate < mval.rate:
            mval = cv
    mval

# compress valves graph to remove items with zero rate and two connected nodes
# exclude the start node
proc compress(vlv: var Table[string, Valve], start: string) =
    let vlist = vlv.values.toSeq
    for v in vlist:
        if v.rate == 0 and v.nodes.len == 2 and v.name != start:
            let cn = v.nodes.toSeq
            let n1 = cn[0]
            let n2 = cn[1]
            n1.nodes.excl(v)
            n2.nodes.excl(v)
            n1.nodes.incl(n2)
            n2.nodes.incl(n1)
            vlv.del(v.name)

