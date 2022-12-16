include ../aoc

type
    Valve = ref object
        name: string
        rate: int
        nodes: seq[Valve]

const csep = ", "
proc `$`(v: Valve): string =
    fmt"{v.name} -> {v.rate} ({v.nodes.mapIt(it.name).join(csep)})"

# Parse data
let data = "16/test".readFile.strip.splitLines
var valves: Table[string, Valve]
for line in data:
    let vlv = line[6..7]
    valves[vlv] = Valve(name: vlv, rate: line[23..24].replace(";","").parseInt)

for line in data:
    let vlv = line[6..7]
    valves[vlv].nodes = line.split(", ").mapIt(valves[it[^2..^1]])

for v in valves.values:
    echo v

# Check that the graph is bi-directional
for v in valves.values:
    for cv in v.nodes:
        assert v in cv.nodes

proc traverseBFS[T](start: T): Table[string, int] =
    var visited: Table[string, int]
    visited[start.name] = 0

    var currentNodes = @[start]
    var depth = 1
    while true:
        var nextNodes: seq[T]
        for cnode in currentNodes:
            for nextNode in cnode.nodes:
                if nextNode.name notin visited:
                    nextNodes.add(nextNode)
                    visited[nextNode.name] = depth
                # else:
                #     # Test for cycles
                #     if visited[nextNode.name] < depth-2:
                #         echo fmt"cycle: {cnode.name} -> {nextNode.name}"
        if nextNodes.len == 0:
            break
        inc depth
        currentNodes = nextNodes
    visited

var loc = "AA"
var timeLeft = 30
var totalPressure = 0
var valvesRate = 0
var openValves: HashSet[string]
while true:
    let cvalverate = valves[loc].rate
    echo ""
    echo fmt"== Minute {31-timeLeft} =="
    if openValves.len == 0:
        echo "No valves are open."
    elif openValves.len == 1:
        echo fmt"Valve {openValves.toSeq.join(csep)} is open, releasing {valvesRate} pressure."
    else:
        echo fmt"Valves {openValves.toSeq.join(csep)} are open, releasing {valvesRate} pressure."
    # totalPressure += valvesRate
    
    # Set rate to zero, as it's open so it isn't counted anymore
    valves[loc].rate = 0

    let nextSteps = valves[loc].traverseBFS.pairs.toSeq
    
    let goLocs = nextSteps.mapIt((timeLeft-it[1]-1) * valves[it[0]].rate).maxIndex
    timeLeft -= nextSteps[goLocs][1]
    let goHere = nextSteps[goLocs][0]
    if goHere == loc:
        break
    echo fmt"Walk {nextSteps[goLocs][1]} steps to {goHere}."
    totalPressure += valvesRate * nextSteps[goLocs][1]
    
    if cvalverate > 0:
        openValves.incl(loc)
    valvesRate += cvalverate

    loc = goHere

echo ""
echo totalPressure + timeLeft * valvesRate