include ../aoc

type
    Mineral = enum Ore, Clay, Obsidian, Geode
    Goods = array[Mineral, int]
    Robots = array[Mineral, int]
    Blueprint = array[Mineral, Goods]
    Situation = object
        blueprint: Blueprint
        inventory: Goods
        robots: Robots

let cb = "19/test".readFile.strip.splitLines

const scanl = "Blueprint $i: Each ore robot costs $i ore. Each clay robot costs $i ore. Each obsidian robot costs $i ore and $i clay. Each geode robot costs $i ore and $i obsidian."
var blueprints: seq[Blueprint]
for li, line in cb:
    var (_, bp, rbO, rbCO, rbBO, rbBC, rbGO, rbGB) = line.scanTuple(scanl)
    var items: Blueprint
    items[Ore] = [rbO, 0, 0, 0]
    items[Clay] = [rbCO, 0, 0, 0]
    items[Obsidian] = [rbBO, rbBC, 0, 0]
    items[Geode] = [rbGO, 0, rbGB, 0]
    assert li == bp-1
    blueprints.add(items)

proc `<=`(a, b: Goods): bool =
    for i in Mineral:
        if a[i] > b[i]:
            return false
    return true
proc sgn(a: Goods): Goods =
    for i in Mineral:
        result[i] = (if a[i]>0: 1 else: 0)
proc `+`(a, b: Goods): Goods =
    for i in Mineral:
        result[i] = a[i] + b[i]
proc `-`(a, b: Goods): Goods =
    for i in Mineral:
        result[i] = a[i] - b[i]
proc `-=`(a: var Goods, b: Goods) = a = a-b

proc runRobots(bench: var Situation) =
    for m in Mineral:
        bench.inventory[m] += bench.robots[m]

proc tryBuild(bench: var Situation, rb: Mineral, nrb: var Option[Mineral]): bool =
    if bench.blueprint[rb] <= bench.inventory:
        bench.inventory -= bench.blueprint[rb]
        nrb = some(rb)
        return true
    else:
        nrb = none(Mineral)
        return false

proc turnsToBuild(bench: Situation, rb: Mineral): int =
    var tinv = bench.inventory

    # Have robots to eventually build it?
    if bench.blueprint[rb].sgn <= bench.robots:
        # How long will it take?
        # inventory + robots * turns > blueprint[rb]
        # turns = (blueprint[rb] - inventory) / robots
        # (2-2)/1 => 0 (0)
        # (2-1)/3 => 1 (0)
        # (2-5)/2 => 0 (-1)
        # (12-2)/2 => 5 (5)
        # (12-1)/2 => 6 (5)
        # (12-0)/2 => 6 (6)

        for m in Mineral:
            tinv[m] += bench.robots[m]
        
    return 999

proc shouldWait(bench: Situation, rb: Mineral): bool =
    # What mats and how much do I need?
    var required = bench.blueprint[rb] - bench.inventory
    for m in Mineral:
        required[m] = max(0, required[m])

    # if turnsToBuild(rb) < 2:
    #     etc...

    if required[Ore] < 2:
        return true

    return false

# proc canAfford(iv: Goods, rb: Mineral, bp: Blueprint): bool = bp[rb] <= iv

# proc canFutureBuild(iv: Goods, rb: Mineral, robots: Robots, bp: Blueprint): bool =
#     var trob = robots
#     var tinv = iv
#     for count in 1..4:
#         tinv.runRobots(trob)
#         if tinv.canAfford(rb, bp):
#             echo count
#             break
#     return false

var bench: Situation
bench.blueprint = blueprints[0]
bench.robots[Ore] = 1

# Robot collects 1 of its resource type per minute
# Maximize amount of geodes mined
for timeStep in 1..24:
    var newRobot: Option[Mineral]

    if not bench.tryBuild(Geode, newRobot):
        if bench.inventory[Obsidian] < bench.blueprint[Geode][Obsidian]:
            if not bench.tryBuild(Obsidian, newRobot):
                if bench.inventory[Clay] < bench.blueprint[Obsidian][Clay]:
                    discard bench.tryBuild(Clay, newRobot)

    bench.runRobots

    if newRobot.isSome:
        inc bench.robots[newRobot.get]

    # discard bench.inventory.canFutureBuild(Obsidian, bench.robots, bench.blueprint)

    echo fmt"Time: {timeStep}, {bench.inventory}, {bench.robots}"

echo "Geodes: ", bench.inventory[Geode]
