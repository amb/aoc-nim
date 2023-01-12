include aoc
import memo

type
    Valve = ref object
        name: string
        rate: int
        open: bool
        nodes: seq[Valve]

proc `$`(v: Valve): string =
    const csep = ", "
    fmt"{v.name} -> {v.rate} ({v.nodes.mapIt(it.name).join(csep)})"

proc parse(fl: string): Table[string, Valve] =
    let data = fl.readFile.strip.splitLines
    var valves: Table[string, Valve]
    for line in data:
        valves[line[6..7]] = Valve(name: line[6..7], rate: line.ints[0])

    for line in data:
        valves[line[6..7]].nodes = line.split(", ").mapIt(valves[it[^2..^1]])

    # Check that the graph is bi-directional
    for v in valves.values:
        for cv in v.nodes:
            assert v in cv.nodes
    valves

# var valves = parse("16/test")
