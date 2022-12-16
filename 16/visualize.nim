import std/[strformat, strutils, sequtils, tables, sets, random, algorithm]
import pixie

randomize()

type
    Valve = ref object
        name: string
        rate: int
        location: Vec2
        nodes: seq[Valve]

const csep = ", "
proc `$`(v: Valve): string =
    fmt"{v.name} -> {v.rate} ({v.nodes.mapIt(it.name).join(csep)})"

# Parse data
let data = "16/input".readFile.strip.splitLines
var valves: Table[string, Valve]
for line in data:
    let vlv = line[6..7]
    valves[vlv] = Valve(name: vlv, rate: line[23..24].replace(";","").parseInt)

for line in data:
    let vlv = line[6..7]
    valves[vlv].nodes = line.split(", ").mapIt(valves[it[^2..^1]])

for k in valves.keys:
    echo valves[k]
    valves[k].location = vec2((rand(512)+256-256).float, (rand(512)+256-256).float)

let colWhite = color(1, 1, 1, 1)
let colBlack = color(0, 0, 0, 1)
let colRed = color(1, 0, 0, 1)
let colGreen = color(0, 1, 0, 1)

let image = newImage(512, 512)
image.fill(colWhite)

var font = readFont("notosans.ttf")
font.size = 12
# font.paint.color = colWhite

proc drawNode(ctx: var Context, loc: Vec2, text: string) =
    ctx.fillStyle = colBlack
    let circleSize = 10.float
    ctx.fillCircle(circle(loc, circleSize+3))

    ctx.fillStyle = colGreen
    ctx.fillCircle(circle(loc, circleSize))

    image.fillText(
        font.typeset(
            text, 
            vec2(circleSize*2, circleSize*2), 
            HorizontalAlignment.CenterAlign, 
            VerticalAlignment.MiddleAlign
        ), 
        translate(loc - vec2(circleSize, circleSize)))

# Try and equalize edge lengths
let normLength = 40.float
let normStep = 10.float
for _ in 0..5000:
    for k in valves.keys:
        var vloc = valves[k].location

        valves[k].location.x = vloc.x.clamp(10.0, 502.0)
        valves[k].location.y = vloc.y.clamp(10.0, 502.0)

        var angles: seq[(float, int)]
        for kci, kc in valves[k].nodes:
            var bloc = valves[kc.name].location
            # assert bloc.x < 1024 and bloc.y < 1024 and bloc.x > -512 and bloc.y > -512

            let diff = bloc-vloc
            let diffl = diff.length
            let dir = diff/diffl

            var vang = dir
            vang.y = -vang.y
            # Y was flipped (facepalm)
            let ang = vang.angle.float
            angles.add((ang, kci))

            if diffl < normLength-normStep:
                valves[k].location -= dir * normStep
                valves[kc.name].location += dir * normStep
            elif diffl > normLength+normStep:
                valves[k].location += dir * normStep
                valves[kc.name].location -= dir * normStep

        let aMove = normStep/4
        let desiredAngle = (2.0*PI)/(angles.len.float)
        # echo fmt"For count: {angles.len}, angle has to be: {desiredAngle}"
        angles.sort()
        for ai in 0..<angles.len-1:
            assert angles.len > 1
            let ang0 = angles[ai]
            var ang1 = angles[ai+1]
            let idx = (ang0[1], ang1[1])
            let name0 = valves[k].nodes[idx[0]].name
            let name1 = valves[k].nodes[idx[1]].name
            # while ang1[0] < ang0[0]:
            #     assert ai == angles.len-1
            #     ang1[0] += 2.0 * PI
            let adiff = ang1[0] - ang0[0]
            assert adiff >= 0.0
            assert adiff <= 2.0 * PI
            var avec = (valves[name0].location-vloc).normalize
            var bvec = (valves[name1].location-vloc).normalize
            if adiff > desiredAngle + 0.2:
                # Move closer
                # Rotate 90, add by differential amount
                # CW
                valves[name0].location += vec2(avec.y, -avec.x)*aMove
                # CCW
                valves[name1].location += vec2(-bvec.y, bvec.x)*aMove
            elif adiff < desiredAngle - 0.2:
                # Move further
                valves[name0].location += vec2(-avec.y, avec.x)*aMove
                valves[name1].location += vec2(bvec.y, -bvec.x)*aMove

    # valves["AA"].location = vec2(256.0, 256.0)

# Draw edges
for k in valves.keys:
    let vloc = valves[k].location
    var ctx = newContext(image)
    ctx.strokeStyle = "#FFFFFF"
    ctx.lineWidth = 6
    for kc in valves[k].nodes:
        let bloc = valves[kc.name].location
        ctx.strokeSegment(segment(vloc, bloc))
    ctx.strokeStyle = "#000000"
    ctx.lineWidth = 3
    for kc in valves[k].nodes:
        let bloc = valves[kc.name].location
        ctx.strokeSegment(segment(vloc, bloc))

# Draw nodes
for k in valves.keys:
    let vloc = valves[k].location
    var ctx = newContext(image)
    ctx.drawNode(vloc, k)

image.writeFile("graph.png")
