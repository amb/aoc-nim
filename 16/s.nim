include ../aoc

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

proc releasePressure(vlv: HashSet[string]): int =
    for k in vlv:
        result += valves[k].rate

var loc = "AA"
var timeLeft = 30
var totalPressureRelease = 0

type
    NodeVisitor[T] = object
        path: seq[T]
        score: int

proc traverseDFS[T](start, previous: T, opened: HashSet[string], depth: int): NodeVisitor[T] =
    var path = @[start]
    var score = 0

    var nextopened = opened
    if start.name notin opened and start.rate > 0:
        nextopened.incl(start.name)
    
    if depth < 25 and opened.len <= 6:
        var choices: seq[NodeVisitor[T]]
        for nd in start.nodes:
            if nd != previous or start.nodes.len == 1:
                choices.add(traverseDFS(nd, start, nextopened, depth+1))

        let best = choices[maxIndex(choices.mapIt(it.score))]
        score = best.score
        for v in best.path:
            path.add(v)
        # for v in best.opened:
        #     opened.incl(v)

    # score += releasePressure(opened)
    score += (30-depth) * opened.releasePressure

    return NodeVisitor[T](path: path, score: score)

var opened: HashSet[string]
let res = traverseDFS(valves["AA"], valves["AA"], opened, 0)
echo res.path.mapIt(it.name)
echo res.score
