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
        let vlv = line[6..7]
        valves[vlv] = Valve(name: vlv, rate: line[23..24].replace(";","").parseInt)

    for line in data:
        let vlv = line[6..7]
        valves[vlv].nodes = line.split(", ").mapIt(valves[it[^2..^1]])

    # Check that the graph is bi-directional
    for v in valves.values:
        for cv in v.nodes:
            assert v in cv.nodes
    valves

var valves = parse("16/test")
for v in valves.values:
    echo v

proc releasedPressure(vlv: HashSet[string]): int =
    for k in vlv:
        result += valves[k].rate

var loc = "AA"
var timeLeft = 30
var totalPressureRelease = 0
